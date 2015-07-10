package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"strconv"
	"strings"
	"time"
)

type PodStates struct {
	running int
	pending int
	waiting int
	inactive int
	unknown int
}

type PodStat struct {
	dataSet []float64
}

func (s *PodStat) Rate() float64 {
	sum := 0.0
	for _, value := range s.dataSet {
		sum += value
	}
	return sum/float64(len(s.dataSet))
}

func (s *PodStat) AddDataSet(ave float64) {
	s.dataSet = append(s.dataSet, ave)
}

type Stats struct {
	podsStarted PodStat
	podsCreated PodStat
}

func readPodStatesFile(fname string) ([]string, error) {
	var lines []string

	fileData, err := ioutil.ReadFile(fname)
	if err != nil {
		return nil, err
	}

	splitData := strings.Split(string(fileData), "\n")
	for _, line := range splitData {
		if len(line) == 0 {
			continue
		}
		lines = append(lines, line)
	}
	return lines, nil
}

func NewPodStates(data []string) PodStates {
	r, _ := strconv.Atoi(strings.Trim(data[1], " "))
	p, _ := strconv.Atoi(strings.Trim(data[3], " "))
	w, _ := strconv.Atoi(strings.Trim(data[5], " "))
	i, _ := strconv.Atoi(strings.Trim(data[7], " "))
	u, _ := strconv.Atoi(strings.Trim(data[9], " "))

	return PodStates{running: r, pending: p, waiting: w, inactive: i, unknown: u,}
}

func totalPods(s PodStates) int {
	return s.running + s.pending + s.waiting + s.inactive + s.unknown
}

func main () {
	var stats Stats

	flag.Parse()
	fname := flag.Arg(0)
	data, err := readPodStatesFile(fname)
	if err != nil {
		fmt.Printf("Failed to read file %s: %v\n", fname, err)
	}

	dateFormat := "2006-01-02 15:04:05.999999999 -0700 MST"
	fields := strings.Split(data[0], ",")
	lastStates := NewPodStates(fields)
	lastTime, err := time.Parse(dateFormat, fields[0])
	data = data[1:]
	for _, line := range data {
		fields := strings.Split(line, ",")
		currentTime, err := time.Parse(dateFormat, fields[0])
		if err != nil {
			fmt.Printf("Failed to parse date %s: %v\n", fields[0], err)
		}

		currentStates := NewPodStates(fields)
		timeDiff := currentTime.Sub(lastTime).Seconds()
		if currentStates.running > 0 && currentStates.running < totalPods(currentStates) {
			stats.podsStarted.AddDataSet(float64((currentStates.running - lastStates.running)) / timeDiff)
		}
		if totalPods(currentStates) > totalPods(lastStates) {
			stats.podsCreated.AddDataSet(float64(totalPods(currentStates) - totalPods(lastStates)) / timeDiff)
		}
		lastTime = currentTime
		lastStates = currentStates
	}
	fmt.Printf("Pod Create Rate: %f/s\n", stats.podsCreated.Rate())
	fmt.Printf("Pod Start Rate: %f/s\n", stats.podsStarted.Rate())

	minStartRate := 5.0
	if stats.podsStarted.Rate() < minStartRate {
		fmt.Printf("Error: Start rate dropped below %f/s\n", minStartRate)
		os.Exit(1)
	}
}
