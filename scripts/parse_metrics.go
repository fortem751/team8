package main

import "regexp"
import "fmt"
import "strings"
import "io/ioutil"
import "flag"
import "strconv"
import "time"

type Metrics struct {
	data map[string]interface{}
}

type RedFlag struct {
	key string
	tolerance time.Duration
	metricUnits time.Duration
	skipStrings []string
}

func (m *Metrics) ReadMetricsFile(name string) error {
	m.data = make(map[string]interface{})
	quantile := regexp.MustCompile(`.+quantile="0\.99".+[0-9\.\+e]+$`)

	contents, err := ioutil.ReadFile(name)
	if err != nil {
		return err
	}

	for _, line := range strings.Split(string(contents), "\n") {
		// Skip empty lines
		if len(line) < 1 {
			continue
		}

		// Skip comments
		if match, _ := regexp.MatchString("^#", line); match == true {
			continue
		}

		if value := quantile.FindString(line); value != "" {
			kvpair := strings.Split(line, " ")
			v := strings.TrimSpace(kvpair[1])
			k := strings.TrimSpace(kvpair[0])
			if v == "NaN" {
				continue
			} else if val, err := strconv.ParseFloat(v, 64); err == nil {
				m.data[k] = val
			} else {
			}
		}
	}

	return nil
}

func (m *Metrics) findFailures(flags []RedFlag) map[string]interface{} {
	fails := make(map[string]interface{})
	for _, f := range flags {
		for k, v := range m.data {
			skip := false
			for _, s := range f.skipStrings {
				r, _ := regexp.Compile("(?i)"+s)
				skip = skip || r.MatchString(k)
			}

			if match, _ := regexp.MatchString(f.key, k); match == true && !skip {
				t := time.Duration(v.(float64)) * f.metricUnits
				if t > f.tolerance {
					fails[k] = v
				}
			}
		}
	}
	return fails
}

func (m *Metrics) Print() {
	for k, v := range m.data {
		fmt.Printf("%s, %+v\n", k, v)
	}
}

func main () {
	flag.Parse()
	dir := flag.Arg(0)
	var metrics Metrics
	redFlags := []RedFlag {
		{key: `quantile="0.99"`, tolerance: 2 * time.Second, metricUnits: time.Microsecond, skipStrings: []string{`verb="watch"`, `verb="watchlist"`}},
	}

	err := metrics.ReadMetricsFile(dir + "/metrics_after.txt")
	if err != nil {
		fmt.Println(err)
	}

	failures := metrics.findFailures(redFlags)
	for k, v := range failures {
		fmt.Printf("%s: %v\n", k, v)
	}
}
