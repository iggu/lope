# HINTS

## BitBucket.org

* goto https://bitbucket.org/account/settings/ssh-keys/ and new host's ssh-keys
* clone repos of need by the template: `git clone git@bitbucket.org:<user>/<repo>.git`

## DOCKER

```bash
### Stop the daemon
$ systemctl stop docker.service
$ systemctl stop docker.socket
```

```bash
### Start the daemon after config changed
$ systemctl daemon-reload
$ systemctl start docker
```

```bash
### Move cache to another location
E /etc/docker/daemon.json: { "graph": "/home/docker" } 
```
