#!/usr/bin/env bash

set -e

CMD_ID_OUTPUT=$1
echo "==> [DEBUG] 'id' output from host: $CMD_ID_OUTPUT"
if [[ -z $CMD_ID_OUTPUT ]]; then
  echo '==> [ERROR] Unable to run the container since the user is not specified'
  echo '==> [ERROR] Please do `docker run` with `"$(id)"` single cliarg'
  echo '==> [ERROR] Non-sudo operations would be done on behalf of this user'
  exit 1
fi

DKRALS=$2 # the container user alias

DOCKER_BINDS=`mount | grep ^/dev/ | grep -v /etc | awk '{print $3}'`
echo "==> [DEBUG] Docker binds: $DOCKER_BINDS"
if ! (echo $DOCKER_BINDS | grep -qw '\/ws') ; then
  echo "==> [ERROR] '/ws' is not bound; run container with '-v ...:/ws'"
  exit 1
fi

INFO_USER_GROUP=`echo $CMD_ID_OUTPUT | cut -d' ' -f 1,2`
INFO_USER=`echo $INFO_USER_GROUP | cut -d' ' -f1`
INFO_GROUP=`echo $INFO_USER_GROUP | cut -d' ' -f2`
UUID=`echo $INFO_USER | tr '(' '=' | cut -d'=' -f2`
USER=`echo $INFO_USER | tr ')' '(' | cut -d'(' -f2`
UGID=`echo $INFO_GROUP | tr '(' '=' | cut -d'=' -f2`
GROUP=`echo $INFO_GROUP | tr ')' '(' | cut -d'(' -f2`

if [[ "$USER" != "$GROUP" ]]; then
  echo "==> [ERROR] Groupname is not the same as Username ($GROUP != $USER)" >&2
  exit 1
fi

echo "==> [INFO] Bootstraping container on behalf of '$USER'($UUID) / '$GROUP'($UGID)"

SHELL=/bin/bash
HOME=/home/$USER
declare -x ${PKGS:=none}
declare -x ${ADDUSER:=true}
declare -x ${SUDO:=true}
declare -x ${SECRET:=qwe}

export TERM=xterm-256color

if [ -d /home/$USER ]; then
  # mostly likely this is committed container
  echo "Using existing setup"
  cd $HOME/ws
  su $USER
  exit 0
fi

if [ "$PKGS" != "none" ]; then
  set +e
  echo "==> [INFO] Installing aux packages $PKGS"
  /usr/bin/apt-get update
  /usr/bin/apt-get install -y $PKGS
  /usr/bin/apt-get clean
  # /bin/rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
  set -e
fi

if [ "${ADDUSER}" == "true" ]; then
  sudo=""
  if [ "${SUDO}" == "true" ]; then
    sudo="-G sudo"
  fi
  if [ -z "$(getent group ${USER})" ]; then
    /usr/sbin/groupadd -g ${UGID} ${USER}
  fi

  if [ -z "$(getent passwd ${USER})" ]; then
    /usr/sbin/useradd -u ${UUID} -g ${UGID} -G sudo -s ${SHELL} -d ${HOME} -m ${sudo} ${USER} 
    if [ "${SECRET}" == "password" ]; then
      SECRET=$(hex)
      echo "Autogenerated password for user ${USER}: ${SECRET}"
    fi
    echo "${USER}:${SECRET}" | /usr/sbin/chpasswd
    unset SECRET
  fi
fi

[[ ! -L "$HOME/ws" && ! -d "$HOME/ws" ]] && ln -sf /ws $HOME/ws

chown -R ${USER}:${UGID} ${HOME}
chown -R ${USER}:${UGID} /ws
chown -R ${USER}:${UGID} ${HOME}/ws

echo "deblin" > $HOME/.dockername # this file contains the docker image name as a 1st line
chown ${USER}:${UGID} $HOME/.dockername
if [[ -x /.bootstrap.user ]] ; then
    su $USER -c /.bootstrap.user
fi
DKRNM=$(head -n1 $HOME/.dockername)
[[ -z $DKRNM ]] && DKRNM="-"
[[ -z $DKRALS ]] || DKRALS="/$DKRALS"
echo "PS1=\"dkr>\[\033[01;36m\]${DKRNM}${DKRALS}\[\033[00m\]"\
     "\[\033[01;35m\]\u@\h\[\033[00m\] \[\033[01;33m\]\w\[\033[00m\]\$ \""\
     >> ~/.bashrc

echo
cd $HOME/ws
touch ~/.sudo_as_admin_successful # to get rid of annoying message about sudo
echo -e "==> [INFO] 'sudo': default password is 'qwe'"
echo -e "==> [INFO] Starting $SHELL for $USER in container."
su $USER

# exec $@
