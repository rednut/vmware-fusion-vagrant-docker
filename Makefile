FORWARD_DOCKER_PORTS := 1
VAGRANT_RAM := 2048
VAGRANT_CORES := 6
VAGRANT_BOXNAME :=  "docker1"
VAGRANT_ANNOTATION := "docker host"
FORWARD_PORTS := 4243




.PHONY: up ssh-config test

info :
	@echo "CORES=${VAGRANT_CORES} RAM=${VAGRANT_RAM} BOXNAME=${VAGRANT_BOXNAME}"
	@echo "FORWARD_DOCKER_PORTS=${FORWARD_DOCKER_PORTS} FORWARD_PORTS=${FORWARD_PORTS}"


up: info
	vagrant up

ssh-config:
	vagrant ssh-config

