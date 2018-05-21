#!/bin/bash

DEB_PACKAGES='python3 virtualenv git-core mpd sqlite3'
DEST=~/mcg_radio
VENV=$DEST/venv
MCG_GITHOME='https://github.com/MCG-Radio'
MCG_PACKAGES='frontend backend'

function install_debs {
#  sudo apt-get update
  sudo apt-get install -y $DEB_PACKAGES
}

function clone_or_update_repos {

  if [ ! -d $DEST ]; then
    mkdir $DEST
  fi

  for r in $MCG_PACKAGES common
  do
    if [ -d $DEST/$r ]; then
      cd $DEST/$r
      git pull
    else
      cd $DEST
      git clone $MCG_GITHOME/$r.git
    fi
  done
}

function create_or_update_venv {
  if [ -d $VENV ]; then
    rm -rf $VENV
  fi

  for r in $MCG_PACKAGES
  do
    vp = "$VENV"_"$r"
    if [ ! -d $vp ]; then
      mkdir -p $vp
      cd $vp
      virtualenv -p python3 .
    fi

    $vp/bin/pip install -r $DEST/$r/requirements.txt --upgrade
  done
}

function process_common {
  cd $DEST/common

  # systemd services
  sudo cp *.service /etc/systemd/system/
  sudo systemctl daemon-reload

  # database
  sqlite3 ../mcg_radio.db < schema.sql

  # start and enable all
  for s in *.service
  do
    sudo systemctl enable $s
    sudo systemctl start $s
  done
}

install_debs
clone_or_update_repos
create_or_update_venv
process_common
