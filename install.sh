#!/usr/bin/env bash
#
# GratWiFi Installation script
#
# (c) 2010-2013 Herman verschooten
#
# Verify Git is installed:
if [ ! $(which git) ]; then
  echo "Git is not installed, doing it now."
  sudo apt-get -y install git-core
fi

echo "Downloading gwserver"

if [ ! -d "gwserver" ]; then
  git clone git@github.com/Herman-verschooten-bvba/gwserver.git 
else
  cd gwserver
  if [ ! -d '.git' ]; then
    git init
    git remote add origin git@github.com/Herman-verschooten-bvba/gwserver.git 
  fi
  git fetch origin
  git reset --hard origin/master
  cd ..
fi

echo "Now cd into gwserver and run sudo ./install.sh to continue"
