export GOPATH=`pwd`
#echo "go path $GOPATH"
#echo "get"

### setting to way larger than 64k, should be good enough for 100 files.
ulimit -n 999999
go get ./src/main/
#echo "run"


### There are two ways to run this.

### Method 1 : Run the source.
### 	Doesnt work across different OSs
### 	go run src/main/etcdsmoke.go # "http://host01-rack10:2379"

### Method 2 : Run the binary.
### this is cross platform, avoids the ''' object is [linux amd64 go1.3.3 X:precisestack] expected''' error.

bin/main  
