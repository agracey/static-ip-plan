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

if [ ! -f /root/bin/set-static ] || [ ! -f /root/bin/static.env ]
then

cp set-static /root/bin/set-static
cp static.env /root/bin/static.env

fi

if [ -f /etc/rancher/static/STATIC-FAILED ]; then
	systemctl disable --now --no-block elemental-static-network
else
	systemctl enable --now --no-block elemental-static-network
fi

