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
  git clone https://github.com/Herman-verschooten-bvba/gwserver.git 
else
  cd gwserver
  if [ ! -d '.git' ]; then
    git init
    git remote add origin https://github.com/Herman-verschooten-bvba/gwserver.git 
  fi
  git pull origin master
  cd ..
fi

cd gwserver

echo "Now run sudo install.sh to continue"
