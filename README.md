# mac os-x vmware fusion vagrantfile to setup a docker host.

This collection of files will help you to run docker on a vmware fusion guesti vm. 

I have created this because boot2docker and friends dont work with vmware fusion (for me)


Features:
- ensures /vagrant mount
- maps /data to /vagrant/data/$HOSTNAME/
- persistent docker storeage on mac host disk via /data/docker/$docker-container-name/
- saves network ip address to /data/state/$ifname
- saves list of interfaces to /data/state/interfaces
- accepts environment var APT_CACHER to set apt-cacher:port
- configure docker to listen to network and state file



Requirements:
- vagrant
- docker client
- vmware fusion

git clone $REPO

    BOXNAME=docker1 vagrant up --provider=vmware_fusion

once finished vagrant status should show the box running
grab from the output the docker guest vm ip address and export it 

    export DOCKER_IP=x.y.z.s

we should then be able to see the guest dockerhost

I set an alias up like

    alias dockr='docker -H tcp://$DOCKER_IP:4243'

so i can just run 

  dockr ps

  docker -H tcp://$DOCKER_IP:4243 images




** example of running a mongo with a [local] persistent data store

Pulldown a mongo docker image:
  dockr pull dockerfile/mongodb

Start new container running the mongodb:
- as a daemon (-d)
- map docker volume (-v) in vm folder /data/docker/mongodb to container path /data
- map port (-p) 28017 on docker host to 28017 in container
  dockr run -d -v /data/docker/mongodb:/data -p 27017:27017 -p 28017:28017 dockerfile/mongodb

This will map the mongodb database path to data/docker1/docker/mongodb
  ls -l data/docker1/docker/mongodb

You will be able to connect to the mongo database via address $DOCKER_IP on the ports that were mapped earlier




