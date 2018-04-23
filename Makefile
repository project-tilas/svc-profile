.PHONY: install test build serve clean pack serve-container deploy ship

TAG?=$(shell git rev-list HEAD --max-count=1 --abbrev-commit)

export TAG

install:
	dep ensure -vendor-only

test:
	go test ./...

build: install
	go build -ldflags "-X main.version=$(TAG)" -o svc-profile .


clean:
	rm ./svc-profile

pack:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 make build
	docker build -t gcr.io/project-tilas/svc-profile:$(TAG) .

serve: build
	./svc-profile

serve-container: pack
	docker run -d -it -p 8080:8080 --name=svc-profile gcr.io/project-tilas/svc-profile:$(TAG)

upload:
	docker push gcr.io/project-tilas/svc-profile:$(TAG)

deploy:
	envsubst < k8s/deployment.yml | kubectl apply -f -

ship: test pack upload deploy clean