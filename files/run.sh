#!/bin/bash
###############
# built for handling static IPs as part of SLE Micro for Rancher
# when DHCP IP reservations/automations are not possible.
# Called from a plan file - and run.sh
# see https://github.com/rancher-sandbox/elemental-example-plan
#
# variables required:
#        eth_if : ethernet interface to assign static IP
#         nodes : list (string) of nodes and IPs to use in format
#                 "node1:<IP> node2:<IP> ..."
#          mask : Network Mask e.g. 24, 26, etc.
#       MAXWAIT : limit # of seconds for random wait (race handling)
#
###############
set -x -e
eth_if=eth0
nodes="node1:192.168.252.8 node2:192.168.252.9 node3:192.168.252.10"
mask="23"
MAXWAIT=10
rand_wait=$((RANDOM % $MAXWAIT))
if [ ! -d /etc/rancher/static-ifs ]; then
        mkdir -p /etc/rancher/static-ifs
fi
function testNodes() {
        echo testing $*
        sleep $rand_wait
        arping -q -D -I $eth_if -c 3 ${nodeip}
        rc=$?
        echo "result is "$rc
        return $rc
}
function nodeInfo() {
        if [ $setNodeInfo -eq 1 ]; then
                storeID=`awk -F'[ .]' '/search/{print $2}' /etc/resolv.conf`
                # where do you want to use this store-unique info?
                elemental-operator register --label "storeid=$storeID" /oem/registration
        fi
}
function setUp() {
        if [[ "$claimedNode" == "none" ]]; then
                echo "No open IPs found!  Aborting!!"
                exit 1
        fi
        echo "Setting up Node with IP : "$claimedNode"/"$mask
        cat > /etc/sysconfig/network/ifcfg-$eth_if << EOF
STARTMODE=auto
BOOTPROTO='static'
IPADDR=''
EOF
        sed -i -r "s/^IPADDR=''/IPADDR='$claimedNode\/$mask'/" /etc/sysconfig/network/ifcfg-$eth_if
        systemctl restart network
        setNodeInfo=1
        cp /etc/sysconfig/network/ifcfg-$eth_if /etc/rancher/static-ifs/
}
#main
claimedNode="none"
for n in ${nodes}
do
        node=${n//:*}
        nodeip=${n//*:}
        echo ${node} ${nodeip}
        testNodes ${nodeip}
        if [ $? -eq 0 ]; then
                echo "IP is available! Claiming it for "${node}
                claimedNode=${nodeip}
                break
        fi
done
#
# Call the network configuration and restart
setUp
#
# generate store label
nodeInfo
#
echo "Done"