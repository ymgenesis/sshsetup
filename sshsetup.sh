#!/bin/bash
CURRENTDIR=$(PWD)

  ############################
 #		Environment			#
############################

## Colour text variables

R=$(tput setaf 1)
G=$(tput setaf 2)
Y=$(tput setaf 3)
B=$(tput setaf 4)
P=$(tput setaf 5)
C=$(tput setaf 6)
D=$(tput sgr0)
echo

## Border around text function

border () {
    local str="$*"      # Put all arguments into single string
    local len=${#str}
    local i
    for (( i = 0; i < len + 4; ++i )); do
        printf '='
    done
    printf "\n| "$C"$str"$D" |\n"
    for (( i = 0; i < len + 4; ++i )); do
        printf '='
    done
    echo
}

## Main menu prompt function

menuprompt () {
	ANS2=n
	while [ "$ANS2" != "y" -o "$ANS2" != "Y" ];
	do
		read -p "Main Menu? [y/n]: " ANS2
		if [ "$ANS2" = "n" -o "$ANS2" = "N" ];
		then
			continue
		elif [ "$ANS2" = "y" -o "$ANS2" = "Y" ];
		then
			echo
			echo "Returning..."
			echo
			sleep 0.7
			break
		else
			continue
		fi
	done
}

## Proceed prompt function

proceedprompt () {
	ANS4=n
	while [ "$ANS4" != "y" -o "$ANS4" != "Y" ];
	do
		read -p "Proceed? [y/n]: " ANS4
		if [ "$ANS4" = "n" -o "$ANS4" = "N" ];
		then
			continue
		elif [ "$ANS4" = "y" -o "$ANS4" = "Y" ];
		then
			sleep 0.7
			break
		else
			continue
		fi
	done
}

## ~/.ssh check and create function

sshcheckandcreate () {
	SSHDIRVAR=n
	if [ ! -d $HOME/.ssh ];
	then
		read -p ""$C"$HOME/.ssh"$D" does not exist. This is where our ssh keys and config file should be stored. Create it now? [y/n]: " SSHDIRVAR
		if [ "$SSHDIRVAR" = "y" -o "$SSHDIRVAR" = "Y" ];
		then
			echo
			echo "Attempting to backup $HOME/.ssh as sshbak to your home folder just in case. ignore the error this will produce, as"\
			"it means $HOME/.ssh doesn't exist, and we're clear to create it."
			echo
			sleep 1
			cp -r $HOME/.ssh $HOME/sshbak
			echo
			sleep 1
			echo "Creating $HOME/.ssh..."
			echo
			sleep 1
			mkdir $HOME/.ssh
			echo "Created! Continuing..."
			echo
			sleep 0.5
		else
			echo
			echo ""$R"Not creating"$D". This tool requires ~/.ssh/ to exist."
			echo
			echo "Returning..."
			echo
			sleep 3
			continue
		fi
	fi
}

## Remote host variables check function

remotevarcheck () {
		if [ -z ${PORTVAR+x} ];
		then
				echo ""$C"Port"$D" "$R"isn't"$D" set."
				sleep 0.3
			else
				echo
				echo ""$C"Port"$D" "$G"is"$D" set to "$G"$PORTVAR"$D"."
				sleep 0.3
		fi
		if [ -z ${IPVAR+x} ];
		then
				echo ""$C"IP"$D" "$R"isn't"$D" set."
				sleep 0.3
			else
				echo ""$C"IP"$D" "$G"is"$D" set to "$G"$IPVAR"$D"."
				sleep 0.3
		fi
		if [ -z ${USERVAR+x} ];
		then
				echo ""$C"Username"$D" "$R"isn't"$D" set."
				sleep 0.3
			else
				echo ""$C"Username"$D" "$G"is"$D" set to "$G"$USERVAR"$D"."
				sleep 0.3
		fi
		if [ -z ${HOSTVAR+x} ];
		then
				echo ""$C"Hostname"$D" "$R"isn't"$D" set."
				sleep 0.3
			else
				echo ""$C"Hostname"$D" "$G"is"$D" set to "$G"$HOSTVAR"$D"."
				sleep 0.3
		fi
		
		if [ -z ${PORTVAR+x} ] && [ -z ${IPVAR+x} ] && [ -z ${USERVAR+x} ] && [ -z ${HOSTVAR+x} ];
		then
			echo
			echo ""$R"All remote host variables aren't set"$D"."
			echo
			sleep 1
			echo "Please run option 2 first." 
			echo
			menuprompt
			continue
		fi
}


  ############################
 #			Main			#
############################


## Begin main loop

while [ "$ANS" != "6" ]; 
do
	clear
	border "SSH Setup Tool"
	echo
	echo ""$G"1"$D" - Install/Update openssh-server (Linux apt-get)"
	echo ""$G"2"$D" - Configure remote host variables"
	echo ""$G"3"$D" - Setup ssh keys in ~/.ssh & transfer to remote host"
	echo ""$G"4"$D" - Add remote host entry to ~/.ssh/config"
	echo ""$G"5"$D" - Add remote host entry to /etc/hosts"
	echo ""$G"6"$D" - Quit"
	echo
	read -p "Selection: " ANS

## 1. Install/Update openssh-server (sshd)
	
	if [ $ANS = 1 ];
	then

		clear
		border "Install/Update openSSH Server"
		echo
		echo "To install/upgrade openssh-server we need to provide our password to sudo apt-get,"\
		"if we haven't already."
		echo
		sleep 0.7
		sudo apt-get install openssh-server
		echo
		menuprompt
		
	continue

## 2. Configure remote host variables
	
	elif [ $ANS = 2 ];
	then
		clear
		border "Configure Remote Host Variables"
		echo
		PORTVAR=
		IPVAR=
		USERVAR=
		HOSTVAR=
		#Port
		while [[ $PORTVAR = "" ]] || [[ ! "$PORTVAR" =~ ^-?[0-9]+$ ]];
		do
		read -p "Enter remote host's "$C"ssh port"$D": " PORTVAR
			if [ "$PORTVAR" = "" ] || [[ ! "$PORTVAR" =~ ^-?[0-9]+$ ]];
			then
				echo ""$R"Please enter a number"$D"."
				continue
			fi
			break
		done
		#IP
		while [[ $IPVAR = "" ]] || [[ ! $IPVAR =~ ^-?[0-9.]+$ ]];
		do
		read -p "Enter remote host's "$C"IP address"$D": " IPVAR
			if [ "$IPVAR" = "" ] || [[ ! "$IPVAR" =~ ^-?[0-9.]+$ ]];
			then
				echo ""$R"Please enter an ip (x.x.x.x)"$D"."
				continue
			fi
			break
		done
		#Username
		while [[ $USERVAR = "" ]] || [[ $USERVAR = *[[:space:]]* ]];
		do
		read -p "Enter remote host's "$C"username"$D": " USERVAR
			if [ "$USERVAR" = "" ] || [[ "$USERVAR" = *[[:space:]]* ]];
			then
				echo ""$R"Please enter a username without spaces"$D"."
				continue
			fi
			break
		done
		#Hostname
		while [[ $HOSTVAR = "" ]] || [[ $HOSTVAR = *[[:space:]]* ]];
		do
		read -p "Enter remote host's "$C"hostname"$D" (used to name ssh keys and ~/.ssh/config entry): " HOSTVAR
			if [ "$HOSTVAR" = "" ] || [[ "$HOSTVAR" = *[[:space:]]* ]];
			then
				echo ""$R"Please enter a hostname without spaces"$D"."
				continue
			fi
			break
		done
		echo
		sleep 0.5
		echo ""$G"Configured!"$D""
		echo
		menuprompt
		
	continue
		
## 3. Setup & send ssh keys to remote host
	
	elif [ $ANS = 3 ];
	then
	
		clear
		border "Setup & Send SSH Keys"
		echo
		# First check to see if ~/.ssh exists. Create it if it doesn't. Function
		sshcheckandcreate
		cd $HOME/.ssh
		# Check to see if remote host variables are set
		remotevarcheck
		echo
		proceedprompt
		echo
		echo ""$G"Creating"$D" keys "$C"$HOSTVAR"$D" & "$C"$HOSTVAR.pub"$D" at ~/.ssh/. An empty passphrase stores keys in plain text."
		echo
		sleep 0.5
		ssh-keygen -f $HOSTVAR;
		echo
		sleep 0.5
		echo ""$G"Created!"$D""
		echo
		sleep 0.7
		echo "Attempting to send keys to "$C"$IPVAR"$D" on ssh port "$C"$PORTVAR"$D" with username "$C"$USERVAR"$D"."
		echo
		echo ""$P"Note"$D": If this is your first time logging in to "$C"$HOSTVAR"$D", you'll need to respond 'yes' to add its"\
		"fingerprint to your ~/.ssh/known_hosts file. You'll need to provide ssh with "$C"$USERVAR"$D"'s password on "$C"$IPVAR"$D"."
		echo
		sleep 0.7
		proceedprompt
		echo
		ssh-copy-id -i $HOSTVAR.pub -p $PORTVAR $USERVAR@$IPVAR
		sleep 0.7
		echo ""$G"Keys transferred!"$D""
		echo
		sleep 0.7
		echo ""$P"Note"$D": Passwordless login via rsa keys won't work until you run option 4 (add ~/.ssh/config entry)."
		echo
		sleep 0.7
		menuprompt
		
	continue	
	
## 4. Add remote host entry to ~/.ssh/config
	
	elif [ $ANS = 4 ];
	then
	
		clear
		border "Add Entry to ~/.ssh/config"
		CONFIGVAR=$HOME/.ssh/config
		echo
		remotevarcheck
		echo
		proceedprompt
		echo
		#Check to see if ~/.ssh/config exists, backup if it does.
		if [ -e "$CONFIGVAR" ];
		then
			echo "$CONFIGVAR exists. Backing up to ~/.ssh/config.bak first, just in case."
			cp $HOME/.ssh/config $HOME/.ssh/config.bak
			echo
			sleep 0.7
			echo ""$G"Completed backup!"$D" Continuing..."
			echo
			sleep 0.7
		fi
		
		echo "Adding the following entry to the end of "$C"$CONFIGVAR"$D":"
		sleep 0.7
		printf "\nHost\t$HOSTVAR\n\tHostname $IPVAR\n\tUser $USERVAR\n\tPort $PORTVAR\n\tIdentityFile $HOME/.ssh/$HOSTVAR\n"
		echo
		sleep 0.7
		proceedprompt
		echo
		printf "\nHost\t$HOSTVAR\n\tHostname $IPVAR\n\tUser $USERVAR\n\tPort $PORTVAR\n\tIdentityFile $HOME/.ssh/$HOSTVAR\n" >> $CONFIGVAR
		echo ""$G"Entry added!"$D" Here's what "$C"$CONFIGVAR"$D" looks like now:"
		echo
		sleep 0.7
		cat $CONFIGVAR
		echo
		sleep 0.7
		echo ""$R"Important"$D": You can only login to "$C"$HOSTVAR"$D" without a password by executing "$G"ssh $HOSTVAR"$D""
		echo
		echo "'ssh -p $PORTVAR $USERVAR@$IPVAR' will prompt you for a password"
		echo
		sleep 0.7
		menuprompt
		
	continue
	
## 5. Add remote host entry to /etc/hosts
	
	elif [ $ANS = 5 ];
	then
	
		clear
		border "Add Entry to /etc/hosts"
		HOSTFILEVAR=/etc/hosts
		echo
		remotevarcheck
		echo
		proceedprompt
		echo
		#Check to see if /etc/hosts exists (it will exist), back it up in case.
		if [ -e "$HOSTFILEVAR" ];
		then
			echo "Backing up "$C"$HOSTFILEVAR"$D" to "$C"/etc/hosts.bak"$D", just in case."
			echo
			echo ""$R"Important"$D": By default on most systems, "$C"$HOSTFILEVAR"$D" is owned by root. This means all regular users"\
			"need to use "$C"sudo"$D" to manipulate the file. You may be asked for your password to access the file now."
			sudo cp /etc/hosts /etc/hosts.bak
			echo
			sleep 0.7
			echo ""$G"Completed backup!"$D" Continuing..."
			echo
			sleep 0.7
		fi
		echo "Adding the following entry to the end of "$C"$HOSTFILEVAR"$D":"
		sleep 0.7
		echo
		echo "$IPVAR $HOSTVAR"
		echo
		sleep 0.7
		proceedprompt
		echo
		echo $IPVAR $HOSTVAR | sudo tee -a /etc/hosts >/dev/null
		echo ""$G"Entry added!"$D" Here's what "$C"$HOSTFILEVAR"$D" looks like now:"
		echo
		sleep 0.7
		sudo cat $HOSTFILEVAR
		echo
		sleep 0.7
		echo ""$P"Note"$D": You can now type "$C"$HOSTVAR"$D" instead of "$C"$IPVAR"$D" where necessary."
		echo
		sleep 0.7
		menuprompt
		
	continue

## 6. Quitting
	
	elif [ $ANS = 6 ];
	then
		echo
		echo "Quitting..."
		echo
		sleep 0.7
	
	else
		echo
		echo "$R"Invalid selection. Returning..."$D"
		echo
		sleep 0.7
		continue	
	fi
	break
done