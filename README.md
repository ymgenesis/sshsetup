# sshsetup

An interactive Linux/UNIX bash script that attempts to streamline the setup of SSH connections on new systems. It executes as a 'simple' interactive terminal at prompt-level, or as a pretty whiptail menu (if it's installed on your system. If not, it will execute the 'simple' version).

Note: Whiptail should be installed by default on Debian systems. You can also install it using `sudo apt-get install whiptail`.

The following options are presented to the user in both 'simple' and whiptail versions:

1. Install/Update openssh-server (Linux apt-get)
2. Configure remote host variables
3. Setup ssh keys in ~/.ssh & transfer to remote host
4. Add remote host entry to ~/.ssh/config
5. Add remote host entry to /etc/hosts
6. Auto Setup
7. Quit

## 1. Install/Upgrade openssh-server

This option simply executes `sudo apt-get install openssh-server`

Obviously, it won't be successful on systems which don't use apt for a package manager.

## 2. Configure Remote Host Variables

This option interactively prompts the user to enter the port, ip, username, and hostname of the machine they are trying to connect with. It then stores the input into variables, which are called by other options in the script later.

Options 3, 4, & 5 require option 2 be completed.

## 3. Setup SSH Keys in ~/.ssh & Transfer to Remote Host

This option first checks if the directory ~/.ssh exists. If it doesn't, it will prompt the user to create it.

It will then create ssh keys (private and .pub) in ~/.ssh using the hostname variable (set in option 2) as the filename. It executes `ssh-keygen -f $hostname`. The whiptail version automatically creates the keys with no passphrase to increase automation (might change). 

It then uses the variables set in option 2 to transfer the newly created .pub key to the remote host the user is trying to connect with. It executes `ssh-copy-id -i $hostname.pub -p $port $user@$ip`.

It reminds users that passwordless login can't occur until option 4 is complete.

## 4. Add remote host entry to ~/.ssh/config

This option backs up ~/.ssh/config - if it exists - then prompts the user to add an entry based on the variables set in option 2 to ~/.ssh/config. The entry is formatted as such:

```
Host    $hostname
        Hostname $ipaddress
        User $username
        Port $port
        IdentityFile $HOME/.ssh/$hostname
```

This tells the ssh agent the hostname, ip, username, port, and private key location (for more secure authentication & passwordless login, which openssh is configured for by default).

It reminds users that passworless login can now be done using `ssh $hostname`

## 5. Add remote host entry to /etc/hosts

This option prompts the user to backup their /etc/hosts file, then add a simple entry to it using the variables set in option 2. The entry is formatted as such:

`x.x.x.x $hostname`

This simply allows the user to use the remote host's hostname instead of an ip address. For example: `http://meaningoflife/` instead of `http://192.168.1.42/`

## 6. Auto Setup

This option simpy runs options 2 to 5 in succession on the terminal to cut down on user prompting. THe script stops once at the beginning to ask the user if the remote host variables they input are correct. A couple of commands prompt the user for info (ssh key passphrases, ssh passwords, sudo passwords) along the way.

When complete, the auto setup process will stop and prompt the user to return to the main menu. It's recommended to look through the auto setup process output before returning to the main menu, as it will complete many tasks without prompting the user.

## 7. Quit

Quits the script, unsetting all variables. 
