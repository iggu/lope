# Automation

## build process

define the following helper function:
    function debuild() { docker build . -f docker/Dockerfile.de$1 --build-arg UTAG=$2 -t de$1:u$2 ${@:3} ; }
it accepts variable part of name of the dockerfile (i.e. letters after 'Dockerfile.de')
and version of ubuntu it is base on (currently 20.04 or 22.04, and partially 18.04)
Possibly intermediate releases (.10) are also supported - but none of them were tested.

run it from the lope/ root like:
    debuild blin 22.04 or `debuild shlin 20.04`

to rebuild the whole chain - simple use can be applied:
    for tag in blin shlin lvim ; do echo "==== $tag ====" && debuild $tag 22.04 || break ; done
to rebuild from scratch - use `--no-cache` option at last position when calling `debuild` function

## running images

same approach:
    function derun() { docker run -it --rm -v $HOME:/ws de$1:u$2 "$(id)" ${@:3} ; }

## commit running container

lvim container requires some time to startup; once initialized - one can save it by running
    docker commit %id% delvim:u22.04r
(consider the 'r' suffix)

to know the `%id%` of the container one can either:
- run `docker ps` and examine the output
- take it from container's shell prompt, digits right after '@': `dkr>delvim user@18518fcd3b30 ~/ws$`

to run it with `derun` function just in the same manner but append the suffix to the tag

# TODO

- implement bash script `dedok` which
    - accepts various commands like `build`, `run`, `save`, `resume`
    - operate only on lope's 'de+' containers interactively.
