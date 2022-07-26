#!/bin/bash

# TODO: only for debugging
env

if [ -f /etc/systemd/system/elemental-static-network.service ]
then

cp elemental-static-network.service /etc/systemd/system/elemental-static-network.service

fi


if [ -f /root/bin/elemental_static-ifs ]
then

cp elemental-static-network.service  /root/bin/elemental_static-ifs

fi


./set-static 
