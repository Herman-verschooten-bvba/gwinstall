#!/bin/bash
#
# GratWiFi Installation script
#
# (c) 2010-2013 Herman verschooten
#
echo "Downloading gwserver"
git clone https://github.com/Herman-verschooten-bvba/gwserver.git 

cd gwserver

./install.sh
