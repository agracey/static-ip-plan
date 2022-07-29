#!/bin/bash

# TODO: only for debugging
set -x

if [ ! -f /etc/systemd/system/elemental-static-network.service ]
then

cp elemental-static-network.service /etc/systemd/system/elemental-static-network.service

fi


if [ ! -f /root/bin/elemental_static-ifs ]
then

cp elemental_static-ifs  /root/bin/elemental_static-ifs

fi

./set-static 

if [ -f /etc/rancher/static/STATIC-FAILED ]; then
	systemctl disable elemental-static-network
else
	systemctl enable elemental-static-network
fi

