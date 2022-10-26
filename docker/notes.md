# Installation

```bash
sudo apt install docker.io # dont care about the latest version
sudo service docker stop # prepare to edit configs
sudo nano /etc/docker/daemon.json # { "data-root": "/path/to/docker/storage" }
sudo sudo rsync -aP /var/lib/docker/ /path/to/docker/storage # if need and want
sudo service docker start # go
sudo groupadd docker # this group allows to run docker wo sudo
sudo usermod -aG docker $USER # grant this right to current user
newgrp docker # try to activate new group for the user wo logout/login
```

# Automation

## build process

```bash
# single image builder
# $1 = variable part of name of the dockerfile (i.e. letters after 'Dockerfile.de')
# $2 = version of ubuntu it is base on (currently 20.04 or 22.04, and partially 18.04)
#      (possibly intermediate releases (.10) are also supported - but none of them were tested)
function debuild() { docker build . -f docker/Dockerfile.de$1 --build-arg UTAG=$2 -t de$1:u$2 ${@:3} ; }

# single image builder invocation example
debuild blin 22.04 or `debuild shlin 20.04`

# build them all - copy text from 'for' word if dont want to rebuild unchanged
REBUILD=--no-cache for tag in blin shlin lvim ; do echo "==== $tag ====" && debuild $tag 22.04 $REBUILD || break ; done
```

## running images

```bash
function derun() { docker run -it --rm -v $HOME:/ws de$1:u$2 "$(id)" ${@:3} ; }
```

## commit running container

```bash
# to know the desired container's id
#   - do 'docker ps'
#   - form container's shell prompt, digits right after '@': `dkr>delvim user@18518fcd3b30 ~/ws$`
# naming convention: base image name + 'r' suffix
docker commit %id% delvim:u22.04r

# then do 'derun'
```

# TODO

- implement bash script `dedok` which
    - accepts various commands like `build`, `run`, `save`, `resume`
    - operate only on lope's 'de+' containers interactively.
