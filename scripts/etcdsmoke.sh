export GOPATH=`pwd`
echo "go path $GOPATH"
echo "get"
go get ./src/main/
echo "run"
go run src/main/etcdsmoke.go "http://host01-rack10:2379"
