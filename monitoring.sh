  GNU nano 5.4                             monitoring.sh                                       
#!/bin/bash

ARC=$(uname -a)
PPROC=$(grep 'physical id' /proc/cpuinfo | uniq | wc -l)
VPROC=$(cat /proc/cpuinfo | grep processor | wc -l)
USED_RAM=$(free -h | grep Mem | awk '{print $3}')
TOTAL_RAM=$(free -h | grep Mem | awk '{print $2}')
RAMPC=$(free | grep Mem | awk '{printf("%.1f"), $3 / $2 * 100}')
USED_DISK=$(df -h --total | grep total | awk '{print $3}')
TOTAL_DISK=$(df -h --total | grep total | awk '{print $2}')
DISKPC=$(df --total | grep total | awk '{print $5}')
PROCPC=$()
LASTBOOT=$(who -b | awk '{print $4, $3}')
LVM=$(if [ $(lsblk | grep lvm | wc -l) -eq 0 ]; then echo no; else echo yes; fi)
NBRCON=$(grep TCP /proc/net/sockstat | awk '{print $3}')
NBRUSER=$(who | wc -l)
IP=$(hostname -I)
MAC=$(ip link | grep ether | awk '{print $2}')
NBRSUDO=$(grep COMMAND /var/log/sudo/sudo.log | wc -l)

wall "
--------------------------SYSTEM INFORMATION--------------------------------
#Architecture: $ARC 
#CPU physical: $PPROC
#vCPU: $VPROC
#Memory Usage: $USED_RAM/$TOTAL_RAM($RAMPC%)
#Disk Usage: $USED_DISK/$TOTAL_DISK ($DISKPC)
#CPU load: $PROCPC
#Last boot: $LASTBOOT 
#LVM use: $LVM
#Connections TCP: $NBRCON ESTABLISHED
#User log: $NBRUSER
#Network: IP $IP($MAC)
#Sudo: $NBRSUDO commands
----------------------------------------------------------------------------
"


