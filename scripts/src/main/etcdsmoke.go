package main

import (
	"fmt"
	"github.com/coreos/go-etcd/etcd"
	"log"
	"time"
	//"os"
)

func getservers() []string {

	s := make([]string, 1000)
	for i, _ := range s {
		if i%3 == 0 {
			s[i] = "http://host01-rack10:2379"
		} else if i%2 == 0 {
			s[i] = "http://host02-rack10:2379"
		} else {
			s[i] = "http://host17-rack11:2379"
		}
	}
	return s
}

func clean(srv []string) {
	client := etcd.NewClient(srv)
	for i, _ := range servers {
		key := fmt.Sprintf("key%v", i)
		print(fmt.Sprintf("\n Deleting... %v ... ", key))
		client.Delete(key, true)
		_, err := client.Get(key, true, false)
		//error should occur, else delete failed~
		if err == nil {
			print(fmt.Sprintf("Failed delete of key %v on cli %v ", key, servers[0]))
			log.Fatal(err)
		} else {
			println("Successfull deletion")
		}
	}
}

func main() {

	fmt.Sprintf("-------------------------------------")

	//http://host01-rack10:2379, http://host01-rack17:2379, ...
	servers := getservers()
	clean(servers)
	print(servers[0])
	for i, _ := range servers {
		key := fmt.Sprintf("key%v", i)
		client := etcd.NewClient(servers[i : i+1])
		print(client)
		print("\n")
		//Each client writes a key w/ unique integer.
		time.Sleep(time.Duration(1) * time.Nanosecond)
		println(fmt.Sprintf("write %v", key))
		if _, err := client.Set(key, key, 9999); err != nil {
			print("FAIL \n")
			log.Fatal(err)
		}
	}

	println("")
	//Verify that each key is reachable from each server
	for i, _ := range servers {
		for _, srv := range servers {
			//Make sure client i has key j.
			client := etcd.NewClient([]string{srv})
			key := fmt.Sprintf("key%v", i)
			println(fmt.Sprintf("asserting server srv=%v has key=%v...", srv, key))
			_, err := client.Get(key, true, false)
			time.Sleep(time.Duration(1) * time.Millisecond)
			// Something went wrong.  This client doesnt have key.
			if err != nil {
				print(fmt.Sprintf("FAIL!!! to get cli %v key %v", srv, key))
				log.Fatal(err)
			}
		}
	}

	clean(servers)
	println("******* PASSED WRITE/GET on all nodes *****")
}
