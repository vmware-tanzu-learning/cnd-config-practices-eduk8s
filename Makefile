# Put it first so that "make" without argument is like "make help".
run: build educates-start

.PHONY: build educates-start educates-stop

educates-start:
	deploy/kind.sh

educates-stop:
	deploy/kind.sh stop

build:
	docker build -t cnd-config-practices:latest .