export GOPATH=`pwd`
#echo "go path $GOPATH"
#echo "get"

### setting to way larger than 64k, should be good enough for 100 files.
ulimit -n 999999
go get ./src/main/
#echo "run"
go run src/main/etcdsmoke.go # "http://host01-rack10:2379"
