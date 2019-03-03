# sshsetup

An interactive Linux/UNIX bash script that presents the following options:

1. Install/Update openssh-server (Linux apt-get)
2. Configure remote host variables
3. Setup ssh keys in ~/.ssh & transfer to remote host
4. Add remote host entry to ~/.ssh/config
5. Add remote host entry to /etc/hosts
6. Quit

## 1. Install/Upgrade openssh-server

This option simply executes `sudo apt-get install openssh-server`

Obviously, it won't be successful on systems which don't use apt for a package manager.

## 2. Configure Remote Host Variables

This option interactively prompts the user to enter the port, ip, username, and hostname of the machine they are trying to connect with. It then stores the input into variables, which are called by other options in the script later.

Options 3, 4, & 5 require option 2 be completed.

## 3 - Setup SSH Keys in ~/.ssh & Transfer to Remote Host

This option first checks if the directory ~/.ssh exists. If it doesn't, it will attempt to back it up as a fail-safe (which will obviously fail), then prompt the user to create it. It will then check if the remote host variables have been set (option 2). If not, it will tell the user to complete option 2, then send the user back to the main menu.

After these conditions are met, it will create ssh keys (private and .pub) in ~/.ssh using the hostname variable (set in option 2) as the filename. It executes `ssh-keygen -f $hostname`.

It then uses the variables set in option 2 to transfer the newly created .pub key to the remote host the user is trying to connect with. It executes `ssh-copy-id -i $hostname.pub -p $port $user@$ip`.

It reminds users that passwordless login can't occur until option 4 is complete.

## 4 - Add remote host entry to ~/.ssh/config

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

## 5 - Add remote host entry to /etc/hosts

This option prompts the user to backup their /etc/hosts file, then add a simple entry to it using the variables set in option 2. The entry is formatted as such:

`x.x.x.x $hostname`

This simply allows the user to use the remote host's hostname instead of an ip address. For example: `http://meaningoflife/` instead of `http://192.168.1.42/`

## 6 - Quit

Quits the script, unsetting all variables. 
