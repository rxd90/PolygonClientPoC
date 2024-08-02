.PHONY: test build docker-build docker-push

test:
	go test -v ./...

build:
	go build -o trustwallet

docker-build:
	docker build -t ricard0/trustwallet:latest .

docker-push:
	docker push ricard0/trustwallet:latest

ci: test build docker-build docker-push