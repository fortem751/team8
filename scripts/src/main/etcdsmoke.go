package main

import (
	"fmt"
	"github.com/coreos/go-etcd/etcd"
	"log"
	"time"
	//"os"
)

func main() {

	fmt.Sprintf("-------------------------------------")

	//http://host01-rack10:2379, http://host01-rack17:2379, ...
	servers := []string{"http://host01-rack10:2379"}

	print(servers[0])
	for i, _ := range servers {
		key := fmt.Sprintf("key%v", i)
		client := etcd.NewClient(servers[i : i+1])
		print(client)
		print("\n")
		//Each client writes a key w/ unique integer.
		time.Sleep(time.Duration(1) * time.Second)
		println(fmt.Sprintf("write %v", key))
		if _, err := client.Set(key, key, 100); err != nil {
			print("FAIL \n")
			log.Fatal(err)
		}
	}

	println("")
	//Verify that each key is reachable from each server
	for i, _ := range servers {
		for j, srv := range servers {
			//Make sure client i has key j.
			client := etcd.NewClient([]string{srv})
			key := fmt.Sprintf("key%v", j)
			print(fmt.Sprintf("asserting key cli=%v key=%v\n", srv, key))
			_, err := client.Get(key, true, true)

			// Something went wrong.  This client doesnt have key.
			if err != nil {
				print(fmt.Sprintf("Failed to get cli %v key %v", i, key))
				log.Fatal(err)
			} else {
				println("Tested passed!.")
			}
		}
	}
}
