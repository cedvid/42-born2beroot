#!/bin/bash

ARC=$(uname -a)
PPROC=$(grep 'physical id' /proc/cpuinfo | uniq | wc -l)
VPROC=$(cat /proc/cpuinfo | grep processor | wc -l)
RAMPC=$(echo "in progress")
MEMPC=$(echo "in progress")
PROCPC=$(echo "in progress")
LASTBOOT=$(who -b | awk '{print $4, $3}')
LVM=$(echo "in progress")
NBRCON=$(echo "in progress")
NBRUSER=$(who | wc -l)
IPVMAC=$(echo "in progress")
NBRSUDO=$(echo "in progress")

wall "
--------------------------SYSTEM INFORMATION--------------------------------
#Architecture: $ARC 
#CPU physical: $PPROC
#vCPU: $VPROC
#Memory Usage: $RAMPC
#Disk Usage: $MEMPC
#CPU load: $PROCPC
#Last boot: $LASTBOOT 
#LVM use: $LVM
#Connections TCP:$NBRCON
#User log: $NBRUSER
#Network: $IPVMAC
#Sudo: $NBRSUDO commands
----------------------------------------------------------------------------
"

