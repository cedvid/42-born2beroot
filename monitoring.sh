#!/bin/bash

# prints info about the system and its kernel
ARC=$(uname -a)
# looks for unique physical id in /proc/cpuinfo and prints number of lines
PPROC=$(grep 'physical id' /proc/cpuinfo | uniq | wc -l)
# looks for processor in /proc/cpuinfo and prints number of lines
VPROC=$(cat /proc/cpuinfo | grep processor | wc -l)
# prints the third field (used) of line containing Mem from command free
USED_RAM=$(free -h | grep Mem | awk '{print $3}')
# prints the second field (total) of line containing Mem from result of command free
TOTAL_RAM=$(free -h | grep Mem | awk '{print $2}')
# Calculate and print the percentage of RAM used
RAMPC=$(free | grep Mem | awk '{printf("%.1f"), $3 / $2 * 100}')
# prints the third field (used disk) from the line containing total from result of command df
USED_DISK=$(df -h --total | grep total | awk '{print $3}')
# prints the second field (total)
TOTAL_DISK=$(df -h --total | grep total | awk '{print $2}')
# prints the fifth fiedl (used percentage)
DISKPC=$(df --total | grep total | awk '{print $5}')
# prints the sum of second and fourth fields (percentages of user and system CPU usage) of Cpu line from result of command top
PROCPC=$(top -bn1 | grep Cpu | awk '{print $2+$4}')
# prints the date and time of last boot
LASTBOOT=$(who -b | awk '{print $3, $4}')
# if result from command lsblk contains lines with lvm then yes, else no
LVM=$(if [ $(lsblk | grep lvm | wc -l) -eq 0 ]; then echo no; else echo yes; fi)
# prints the third field (in use) from line TCP from /proc/net/sockstat
NBRCON=$(grep TCP /proc/net/sockstat | awk '{print $3}')
# prints number of users
NBRUSER=$(who | wc -l)
# prints IP address
IP=$(hostname -I)
# prints second field of line ether which is MAC address
MAC=$(ip link | grep ether | awk '{print $2}')
# prints number of lines containing COMMAND which is number of sudo commands
NBRSUDO=$(grep COMMAND /var/log/sudo/sudo.log | wc -l)

wall "
--------------------------SYSTEM INFORMATION--------------------------------
#Architecture: $ARC 
#CPU physical: $PPROC
#vCPU: $VPROC
#Memory Usage: $USED_RAM/$TOTAL_RAM($RAMPC%)
#Disk Usage: $USED_DISK/$TOTAL_DISK ($DISKPC)
#CPU load: $PROCPC%
#Last boot: $LASTBOOT 
#LVM use: $LVM
#Connections TCP: $NBRCON ESTABLISHED
#User log: $NBRUSER
#Network: IP $IP($MAC)
#Sudo: $NBRSUDO commands
----------------------------------------------------------------------------
"


