# BORN2BEROOT
This is a 42 school project. The goal is to explore the basics of system administration by creating a virtual machine and installing and configuring a Debian server from scratch. Through this project, I gained essential knowledge about virtualization, operating systems, disk partitioning (with LVM), tools such as SSH (for remote access to the server), UFW (for firewall management), cron (for system scheduled tasks) and I was able to deepen my understanding of bash scripting and my overall proficiency with command lines.

## MANDATORY PART: STEP-BY-STEP GUIDE

Disclaimer: My only goal is to document the steps I took in order to complete the project. If you are a 42 student, make sure you do your own research and understand what you do. You will be asked many questions during the evaluation and you need to be confident navigating around your server.

### Installation

- Download a disk image of the latest stable version of Debian on their official website
- Create a new Virtual Machine with VirtualBox.
  - New
  - Name your machine
  - Version is Debian 64 bits
  - Keep RAM as 1024MB, it's enough
  - Create a virtual hard disk now
  - Select VDI (VirtualBox Disk Image)
  - Dynamically allocated
  - 8G is enough for the mandatory part and the bonus (no need to allocate 30G like the example
  - In the settings of your machine, click Storage, click Empty under controller IDE, select your downloaded image as Optical Drive and confirm
  - Now you can start your machine
- Select the appropriate location, timezone and set hostname and username as per requirements
- You will need to create the partitions manually and encrypt at least two partitions
  - Select Manual
  - Select the disk (there should be only one option of 8G)
  - Create new empty partition -> Yes
  - Select Free Space
  - Create a new partition (this will be the boot partition)
    - 500MB
    - Primary
    - Beginning
    - Mount point: boot
    - Done
   - Again, select Free space and create a new partition
      - Select max size
      - Select Logical
      - Do not mount it
      - Done
   - Configure encrypted volumes
      - Write the changes? -> Yes
      - Create encrypted volume
      - Select sda5
      - Done
      - Finish
      - Really erase? Yes
   - Type your encryption passphrase
   - Select Configure the Logical Volume Manager
   - Write the changes? Yes
   - Create Volume Group -> LVMGroup as per subject -> Select sda5
   - Create Logical Volume
      - root -> 2G
      - swap -> 1024M
      - home -> 1G
      - var -> 1G
      - srv -> 1G
      - tmp -> 1G
      - var-log -> all the rest
      - Finish
   - Now you will need to select each partition and for Use as, select ext4 (except for swap which is a swap area)
   - Select the appropriate mount point for each partition (for var-log you will need to enter manually /var/log)
   - Finish and Write changes
- For Software Selection, unselect everything, we will install all we need ourselves (Don't install a graphical environment such as Gnome, you will fail the project)
- Instal GRUB Boot loader -> Yes
- And you are done! You can now restart your machine and start configuring your server
   
  

### Configuration of the server

If you logged in with your name, you can switch to root with these lines:

`$ su root`

OR

`$ su -`

#### Install and config of SUDO

Install sudo with:

    $ apt update
    $ apt upgrade
    $ apt install sudo

You can use this command to check if an installation is successful:

`$ dpkg -l | grep <package_name>`

Add existing user to sudo:

`$ sudo usermod -aG sudo <user>`

OR

`$ sudo adduser <username> sudo`

Create a group 'user42' as per requirement:

`$ sudo groupadd user42`

Add the existing user to the group:

`$ sudo usermod -aG user42 <username>`

OR

`$ sudo adduser <username> user42`

You can use this line to display members of a group:

`$ getent group <group>`

As per requirement, create a directory to save logs of all sudo inputs and outputs:

`$ sudo mkdir /var/log/sudo`

**The /etc/sudoers file is a configuration file that controls user access to the 'sudo' command. We use 'visudo' which provides a safe and secure way to edit the file. 'visudo' locks the sudoers file against multiple simultaneous edits and it will check for syntax errors.**

Add this line to sudoers file:

`<username>  ALL=(ALL:ALL) ALL`

**Note: the file already contains this line for root.
This will give unlimited privileges to 'username' as well.**

Add these defaults settings as per requirements:

    Defaults	passwd_tries=3
    Defaults	badpass_message="Custom message in case of bad password"
    Defaults	logfile="/var/log/sudo/sudo.log"
    Defaults	log_input
    Defaults	log_output
    Defaults	requiretty

**'requiretty' provides an additional layer of security by ensuring that the user has an interactive TTY session before they can run a command with elevated privileges.
This helps to prevent unauthorized users from running 'sudo' commands remotely or from scripts.**

Add this line to restrict the paths that can be used by 'sudo':

`Defaults   secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"`

**This means when a user runs a 'sudo' command, the system will only look for the command in the specified directories (which are considered to be safe and not writeable by anyone except the root user). If the command is not located in any of these, the user will not be allowed to run it with elevated privileges.
Without this line, regular users without elevated privileges may be able to place their own executables and wait for a user with sudo rights to accidentally execute it.**

#### Install and config of SSH

Install SSH:

`$ sudo apt install openssh-server`

Configure the ssh file to listen for incoming connections on port 4242 instead of default port 22.

`$ sudo nano /etc/ssh/sshd_config`

Replace this line:

`#Port 22` with `Port 4242`

Disable ssh login as root:

Replace this line `#PermitRootLogin prohibit-password` with `PermitRootLogin no`

Restart SSH:

`$ systemctl restart ssh`
    
Check status with:

`$ sudo service ssh status`

OR

`$ systemctl status ssh`

You should now see that SSH is active and listening to port 4242

#### Install and config of UFW

Install ufw:

`$ sudo apt install ufw`

Enable UFW:

`$ sudo ufw enable`

Allow port 4242

`$ sudo ufw allow 4242`

Check status with:

`$ sudo ufw status`

It should show the following:

To		Action	From

4242		ALLOW	Anywhere

4242(v6)	ALLOW	Anywhere (v6)

Exit the virtual machine and go to VirtualBox software and add a port forwarding rule for 4242:
- Click on your Virtual Machine
- Settings
- Network
- Adapter 1
- Advanced
- Port Forwarding
- Set Host Port to 4242 and Guest Port to 4242
- Ok

Boot your VM and restart SSH. Open a terminal on your physical machine, you should now be able to connect to your VM via SSH with this command:

`$ ssh <username>@localhost -p 4242`

#### Strong password policy:

**The /etc/login.defs file provides defaults configuration information for several user account parameters including password aging controls.**

Edit /etc/login.defs as per requirements:

`$ sudo nano /etc/login.defs`

    // Maximum number of days a password may be used.
    PASS_MAX_DAYS   30   
    // Minimum number of days allowed between password changes.
    PASS_MIN_DAYS   2 
    // Number of days warning given before a password expires.
    PASS_WARN_AGE   7

After saving, you will have to manually apply the changes to existing users (including root):

    $ sudo chage -M 30 <username>
    $ sudo chage -m 2 <username>
    $ sudo chage -W 7 <username>

Display password aging information with:

`$ sudo chage -l <username>`

You should see something like this:

    Last password change: Feb 26, 2023
    Password expires: Mar 28, 2023
    Password inactive: never
    Account expires: never
    Minimum number of days between password change: 2
    Maximum number of days between password change: 30
    Number of days of warning before password expires: 7

Next, install the package libpam-pwquality:

`$ sudo apt install libpam-pwquality`

**libpwquality is a library that provides password quality checking functionality.**

Edit /etc/pam.d/common-password:

`$ sudo nano /etc/pam.d/common-password`

Find this line:

`password requisite pam_pwquality.so retry=3`

And add the following:

`minlen=10 ucredit=-1 lcredit=-1 dcredit=-1 maxrepeat=3 reject_username difok=7 enforce_for_root`

Which respectively stand for:
- Minimun length of 10 characters
- At least one lowercase character
- At least one uppercase character
- At least one digit
- No more than 3 consecutive identical characters
- Cannot contain the username
- Must contain at least 7 characters that are not part of the former password
- All rules apply to root

You can add a new user to test the password requirements:

`$ sudo adduser <username>`

Type a weak password, it should return:

`"BAD PASSWORD: <requirements>"`

Finally, write a simple script [monitoring.sh](https://github.com/cedvid/born2beroot/blob/main/monitoring.sh) that displays the system information on ALL terminals, every 10 minutes.

In order to do that, we will use cron and wall.
**Cron is a utility in Linux that allows users to schedule tasks or commands to run automatically at specified intervals.
Wall command allows us to send a message or the content of a file to all currently logged-in users of the server.**

Save monitoring.sh in /root.

## BONUS PART

### FIRST BONUS

You will need to create a functional WordPress website hosted on your server using lighttpd, mariaDB, PHP.

![wordpress site](https://github.com/cedvid/born2beroot/blob/main/img/wordpress.png?raw=true "Preview of my bonus website")


#### Instal Lighttpd

`$ sudo apt install lighttpd`

Activate lighttpd FastCGI module:

    $ sudo lighty-enable-mod fastcgi
    $ sudo lighty-enable-mod fastcgi-php
    $ sudo service lighttpd force-reload

Allow incoming traffic on port 80 which is the default port for HTTP traffic that lighttpd uses to serve content:

`$ sudo ufw allow 80`

Then set up port forwarding in VirtualBox:

Settings -> Network -> Adapter 1 -> Port Forwarding -> Host port 8080 -> Guest port 80

#### Install and configure MariaDB

Installation:

`$ sudo apt install mariadb-server`

Next, run the following command and follow the prompts to secure your new MariaDB installation.
Make sure to disallow external access: 

`$ sudo mysql_secure_installation`

Configuration:

`$ sudo mariadb`

    MariaDB [(none)]> CREATE DATABASE <name_of_your_wordpress_db>;
    MariaDB [(none)]> CREATE USER 'admin'@'localhost' IDENTIFIED BY 'your_password';
    MariaDB [(none)]> GRANT ALL ON name_of_your_wordpress_db.* TO 'admin'@'localhost' IDENTIFIED     BY 'your_password' WITH GRANT OPTION;
    MariaDB [(none)]> FLUSH PRIVILEGES;
    MariaDB [(none)]> EXIT;

#### Install PHP

`$ sudo apt install php-cgi php-mysql`

#### Install WordPress

First, install wget:

`$ sudo apt install wget`

Use wget to download the latest version of WordPress:

`$ sudo wget http://wordpress.org/latest.tar.gz -P /var/www/html`

**When a web server receives a request for a web page or other content, it looks in the /var/www/html directory to find the appropriate file. The content stored in this directory can include HTML files, images, scripts, stylesheets, and other files that make up a website.**

Extract the content:

`$ sudo tar -xzvf /var/www/html/latest.tar.gz`

Copy the content of /wordpress to /var/www/html:

`$ sudo cp -r /var/www/html/wordpress/* /var/www/html`

Create the WordPress configuration file from the sample file:

`$ sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php`

And edit it according to the mariadb information:

    define( 'DB_NAME', 'name_of_your_wordpress_db' );
    define( 'DB_USER', 'admin' );
    define( 'DB_PASSWORD', 'your_password' );
    define( 'DB_HOST', 'localhost' );

Finally, connect to http://localhost:8080 and follow the WordPress instructions.

### SECOND BONUS:

For the second bonus, I decided to install 'cockpit' as an additional service.
It's a remote server management software with a simple web-based interface.

The installation is very straightforward, here's what the official website recommends:

To get the latest version, we recommend to enable the backports repository (as root):

    . /etc/os-release
    echo "deb http://deb.debian.org/debian ${VERSION_CODENAME}-backports main" > \
        /etc/apt/sources.list.d/backports.list
    apt update

Install or update the package:

`$ apt install -t ${VERSION_CODENAME}-backports cockpit`


For the last time, you can go to VirtualBox software to add a port forwarding rule.

Click on your Virtual Machine -> Settings -> Network -> Adapter 1 -> Advanced -> Port Forwarding -> Set Host Port to 9090 and Guest Port to 90

Allow port 90:

`$ ufw allow 90`

Go to `https://localhost:9090`, you should now be able to use Cockpit and manage your server via your browser.

## USEFUL FOR THE EVALUATION

A virtual machine is a sofware emulation of a physical computer that can run its own operating system and applications, but it exists entirely within another host operating system.
This allows you to run multiple operating systems isolated from each other on a single physical computer. It's particularly useful for testing softwares in a controlled environment.

**apt and aptitude:**

Both are package managers that allow the user to install, update and remove software packages. aptitude is built on top of apt and has more features. It also has a GUI.

**AppArmor and SELinux:**

Both are security modules that enforce security policies. AppArmor uses a profile-based approach, where each process is assigned a profile that defines its access permissions.
SELinux uses a policy-based approach, where access is restricted based on the sensitivity of the data and the role of the user. 
AppArmor is considered to be simpler to set up and manage.



**USEFUL COMMANDS:**

UFW commands:

Check UFW status

`$ sudo ufw status`

Allow a port/protocol

`$ sudo ufw allow <port>/<protocol>`

Deny a port/protocol

`$ sudo ufw deny <port>/<protocol>`

Delete a rule:

`$ sudo ufw delete <rule>    // e.g. sudo ufw delete allow 22/tcp`

Get a numbered list of ports/protocols and delete specifc number
    
    $ sudo ufw status numbered
    $ sudo ufw delete <nbr>

User/group related commands:

Add a new user

`$ sudo adduser <username>`

Delete a user

    $ sudo deluser <username>
    $ sudo deluser --remove-home <username> // to remove home also
    
Create a new group 

`$ sudo addgroup <groupname>`

Delete a group

`$ sudo delgroup <groupname>`

Add a user to a group

`$ sudo adduser <username> <groupname>`

Change the password of a user

`$ sudo passwd <username>`

Display the details of password age 

`$ sudo chage -l <username>`

Change the hostname (you will need to reboot to see the change)

`$ sudo hostnamectl set-hostname <new_hostname>`

Interrupt a service (you will be asked to interrupt cron during the evaluation)

    $ sudo systemctl stop <service>`
    //To check status:
    $ sudo systemctl status <service>
    //To restart the service
    $ sudo systemctl start <service>
