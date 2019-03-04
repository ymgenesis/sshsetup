#!/bin/bash

############################
# 	sshsetup v1.3      #
# Written by Matthew Janik #
############################

  ############################
 #	 Environment	   #
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
    printf "\n| %s |\n" "$C""$str""$D"
    for (( i = 0; i < len + 4; ++i )); do
        printf '='
    done
    echo
}

## Main menu prompt function

menuprompt () {
	ANS2=n
	while [ "$ANS2" != "y" ] && [ "$ANS2" != "Y" ];
	do
		read -rp "Main Menu? [y/n]: " ANS2
		if [ "$ANS2" = "n" ] || [ "$ANS2" = "N" ];
		then
			:
		elif [ "$ANS2" = "y" ] || [ "$ANS2" = "Y" ];
		then
			echo
			echo "Returning..."
			echo
			sleep 0.7
			break
		fi
	done
}

## Proceed prompt function

proceedprompt () {
	ANS4=n
	while [ "$ANS4" != "y" ] && [ "$ANS4" != "Y" ];
	do
		read -rp "Proceed? [y/n]: " ANS4
		if [ "$ANS4" = "n" ] || [ "$ANS4" = "N" ];
		then
			:
		elif [ "$ANS4" = "y" ] || [ "$ANS4" = "Y" ];
		then
			sleep 0.7
			break
		fi
	done
}

## Remote host variables list function

remotevarlist () {
		if [ -z ${PORTVAR+x} ];
		then
				echo "${C}Port${D} ${R}isn't${D} set."
				sleep 0.3
			else
				echo
				echo "${C}Port${D} ${G}is${D} set to ${G}${PORTVAR}${D}."
				sleep 0.3
		fi
		if [ -z ${IPVAR+x} ];
		then
				echo "${C}IP${D} ${R}isn't${D} set."
				sleep 0.3
			else
				echo "${C}IP${D} ${G}is${D} set to ${G}${IPVAR}${D}."
				sleep 0.3
		fi
		if [ -z ${USERVAR+x} ];
		then
				echo "${C}Username${D} ${R}isn't${D} set."
				sleep 0.3
			else
				echo "${C}Username${D} ${G}is${D} set to ${G}${USERVAR}${D}."
				sleep 0.3
		fi
		if [ -z ${HOSTVAR+x} ];
		then
				echo "${C}Hostname${D} ${R}isn't${D} set."
				sleep 0.3
			else
				echo "${C}Hostname${D} ${G}is${D} set to ${G}${HOSTVAR}${D}."
				sleep 0.3
		fi

}

### Option Functions

# Option 1

optionone () {
	echo "To install/upgrade openssh-server we need to provide our password to sudo apt-get,"\
	"if we haven't already."
	echo
	sleep 0.7
	sudo apt-get install openssh-server
	echo
	menuprompt
}

# Option 2

optiontwo () {
	PORTVAR=
	IPVAR=
	USERVAR=
	HOSTVAR=
	#Port
	while [[ $PORTVAR = "" ]] || [[ ! "$PORTVAR" =~ ^-?[0-9]+$ ]];
	do
	read -rp "Enter remote host's ${C}ssh port${D}: " PORTVAR
		if [ "$PORTVAR" = "" ] || [[ ! "$PORTVAR" =~ ^-?[0-9]+$ ]];
		then
			echo "${R}Please enter a number${D}."
		fi
	done
	#IP
	while [[ $IPVAR = "" ]] || [[ ! $IPVAR =~ ^-?[0-9.]+$ ]];
	do
	read -rp "Enter remote host's ${C}IP address${D}: " IPVAR
		if [ "$IPVAR" = "" ] || [[ ! "$IPVAR" =~ ^-?[0-9.]+$ ]];
		then
			echo "${R}Please enter an ip (x.x.x.x)${D}."
		fi
	done
	#Username
	while [[ $USERVAR = "" ]] || [[ $USERVAR = *[[:space:]]* ]];
	do
	read -rp "Enter remote host's ${C}username${D}: " USERVAR
		if [ "$USERVAR" = "" ] || [[ "$USERVAR" = *[[:space:]]* ]];
		then
			echo "${R}Please enter a username without spaces${D}."
		fi
	done
	#Hostname
	while [[ $HOSTVAR = "" ]] || [[ $HOSTVAR = *[[:space:]]* ]];
	do
	read -rp "Enter remote host's ${C}hostname${D} (used to name ssh keys and ~/.ssh/config entry): " HOSTVAR
		if [ "$HOSTVAR" = "" ] || [[ "$HOSTVAR" = *[[:space:]]* ]];
		then
			echo "${R}Please enter a hostname without spaces${D}."
		fi
	done
	echo
	sleep 0.5
	echo "${G}Configured!${D}"
	echo
	menuprompt

}

# Option 3

optionthree () {
	# First check to see if ~/.ssh exists.
	SSHDIRVAR=y
	if [ ! -d "$HOME"/.ssh ];
	then
	read -rp "${C}$HOME/.ssh${D} ${R}does not exist${D}. This is where our ssh keys and config file should be stored. Create it now? [y/n]: " SSHDIRVAR
		
		if [ "$SSHDIRVAR" = "y" ] || [ "$SSHDIRVAR" = "Y" ];
		then
			echo
			echo "Attempting to backup $HOME/.ssh as sshbak to your home folder just in case. ignore the error this will produce, as"\
			"it means $HOME/.ssh doesn't exist, and we're clear to create it."
			echo
			sleep 1
			cp -r "$HOME"/.ssh "$HOME"/sshbak
			echo
			sleep 1
			echo "${C}Creating${D} $HOME/.ssh..."
			echo
			sleep 1
			mkdir "$HOME"/.ssh
			echo "${G}Created${D}! Continuing..."
			sleep 0.5
			
		elif [ "$SSHDIRVAR" = "n" ] || [ "$SSHDIRVAR" = "N" ];
		then
			echo
			echo "${R}Not creating${D}. This tool requires ~/.ssh/ to exist."
			echo
			echo "Returning..."
			echo
			sleep 2
		else
			SSHDIRVAR=y
		fi
	
	elif [ -d "$HOME"/.ssh ];
	then
		cd "$HOME"/.ssh
		remotevarlist
		echo
		# Check to see if remote host variables are set
		if [ -z ${PORTVAR+x} ] && [ -z ${IPVAR+x} ] && [ -z ${USERVAR+x} ] && [ -z ${HOSTVAR+x} ];
		then
			echo "${R}All remote host variables aren't set${D}."
			echo
			sleep 1
			echo "Please run option 2 first." 
			echo
			menuprompt
		 
		else 
			#Continue with ket creation
			proceedprompt
			echo
			echo "${G}Creating${D} keys ${C}${HOSTVAR}${D} & ${C}${HOSTVAR}.pub${D} at ~/.ssh/. An empty passphrase stores keys in plain text."
			echo
			sleep 0.5
			ssh-keygen -f "$HOSTVAR";
			echo
			sleep 0.5
			echo "${G}Created!${D}"
			echo
			sleep 0.7
			echo "Attempting to send keys to ${C}${IPVAR}${D} on ssh port ${C}${PORTVAR}${D} with username ${C}${USERVAR}${D}."
			echo
			echo "${P}Note${D}: If this is your first time logging in to ${C}${HOSTVAR}${D}, you'll need to respond 'yes' to add its"\
			"fingerprint to your ~/.ssh/known_hosts file. You'll need to provide ssh with ${C}${USERVAR}${D}'s password on ${C}${IPVAR}${D}."
			echo
			sleep 0.7
			proceedprompt
			echo
			ssh-copy-id -i "$HOSTVAR".pub -p "$PORTVAR" "$USERVAR"@"$IPVAR"
			sleep 0.7
			echo "${G}Keys transferred!${D}"
			echo
			sleep 0.7
			echo "${P}Note${D}: Passwordless login via rsa keys won't work until you run option 4 (add ~/.ssh/config entry)."
			echo
			sleep 0.7
			menuprompt
		fi
	fi

}

# Option 4

optionfour () {
	remotevarlist
	echo
	CONFIGVAR="$HOME"/.ssh/config
	# Check to see if remote host variables are set
	if [ -z ${PORTVAR+x} ] && [ -z ${IPVAR+x} ] && [ -z ${USERVAR+x} ] && [ -z ${HOSTVAR+x} ];
	then
		echo "${R}All remote host variables aren't set${D}."
		echo
		sleep 1
		echo "Please run option 2 first." 
		echo
		menuprompt
	 
	else 
		proceedprompt
		echo
		if [ -e "$CONFIGVAR" ];
		then
			#Backup ~/.ssh/config
			echo "${C}${CONFIGVAR}${D} exists. Backing it up to ~/.ssh/config.bak first, just in case."
			cp "$HOME"/.ssh/config "$HOME"/.ssh/config.bak
			echo
			sleep 0.7
			echo "${G}Completed backup!${D} Continuing..."
			echo
			sleep 0.7
		fi
	
		echo "Adding the following entry to the end of ${C}${CONFIGVAR}${D}:"
		sleep 0.7
		printf "\nHost\t%s\n\tHostname %s\n\tUser %s\n\tPort %s\n\tIdentityFile %s/.ssh/%s\n" "$HOSTVAR" "$IPVAR" "$USERVAR" "$PORTVAR" "$HOME" "$HOSTVAR"
		echo
		sleep 0.7
		proceedprompt
		echo
		# Print to ~/.ssh/config
		printf "\nHost\t%s\n\tHostname %s\n\tUser %s\n\tPort %s\n\tIdentityFile %s/.ssh/%s\n" "$HOSTVAR" "$IPVAR" "$USERVAR" "$PORTVAR" "$HOME" "$HOSTVAR" >> "$CONFIGVAR"
		echo "${G}Entry added!${D} Here's what ${C}${CONFIGVAR}${D} looks like now:"
		echo
		sleep 0.7
		cat "$CONFIGVAR"
		echo
		sleep 0.7
		echo "${R}Important${D}: You can only login to ${C}${HOSTVAR}${D} without a password by executing ${G}ssh ${HOSTVAR}${D}"
		echo
		echo "'ssh -p ${PORTVAR} ${USERVAR}@${IPVAR}' will prompt you for a password"
		echo
		sleep 0.7
		menuprompt
	fi
}

# Option 5

optionfive () {
	remotevarlist
	echo
	HOSTFILEVAR=/etc/hosts
	# Check to see if remote host variables are set
	if [ -z ${PORTVAR+x} ] && [ -z ${IPVAR+x} ] && [ -z ${USERVAR+x} ] && [ -z ${HOSTVAR+x} ];
	then
		echo "${R}All remote host variables aren't set${D}."
		echo
		sleep 1
		echo "Please run option 2 first." 
		echo
		menuprompt
	
	else
		proceedprompt
		echo
		if [ -e "$HOSTFILEVAR" ];
		then
			#Backup /etc/hosts
			echo "${C}${HOSTFILEVAR}${D} exists. Backing it up to /etc/hosts.bak, just in case."
			echo
			echo "${R}Important${D}: By default on most systems, ${C}${HOSTFILEVAR}${D} is owned by root. This means all regular users"\
			"need to use ${C}sudo${D} to manipulate the file. You may be asked for your password to access the file now."
			sudo cp /etc/hosts /etc/hosts.bak
			echo
			sleep 0.7
			echo "${G}Completed backup${D}! Continuing..."
			echo
			sleep 0.7
		fi	
			
		echo "Adding the following entry to the end of ${C}${HOSTFILEVAR}${D}:"
		sleep 0.7
		echo
		echo "${IPVAR} ${HOSTVAR}"
		echo
		sleep 0.7
		proceedprompt
		echo
		echo "$IPVAR" "$HOSTVAR" | sudo tee -a /etc/hosts >/dev/null
		echo "${G}Entry added${D}! Here's what ${C}${HOSTFILEVAR}${D} looks like now:"
		echo
		sleep 0.7
		sudo cat "$HOSTFILEVAR"
		echo
		sleep 0.7
		echo "${P}Note${D}: You can now type ${C}${HOSTVAR}${D} instead of ${C}${IPVAR}${D} where necessary."
		echo
		sleep 0.7
		menuprompt
	fi
}

  ############################
 #	     Main           #
############################


while [ "$ANS" != "6" ]; 
do

	# Present main menu
	clear
	border "SSH Setup Tool"
	echo
	echo "${G}1${D} - Install/Update openssh-server (Linux apt-get)"
	echo "${G}2${D} - Configure remote host variables"
	echo "${G}3${D} - Setup ssh keys in ~/.ssh & transfer to remote host"
	echo "${G}4${D} - Add remote host entry to ~/.ssh/config"
	echo "${G}5${D} - Add remote host entry to /etc/hosts"
	echo "${G}6${D} - Quit"
	echo
	read -rp "Selection: " ANS

	case $ANS in
		
## 1. Install/Update openssh-server (sshd)		

		1|one|ONE)
		
		clear
		border "Install/Update openSSH Server"
		echo
		optionone
		;;

## 2. Configure remote host variables
		
		2|two|TWO)
		
		clear
		border "Configure Remote Host Variables"
		echo
		optiontwo
		;;

## 3. Setup & send ssh keys to remote host
		
		3|three|THREE)
		
		clear
		border "Setup & Send SSH Keys"
		echo
		optionthree
		;;

## 4. Add remote host entry to ~/.ssh/config
			
		4|four|FOUR)
		
		clear
		border "Add Entry to ~/.ssh/config"
		echo
		optionfour
		;;

## 5. Add remote host entry to /etc/hosts
		
		5|five|FIVE)
		
		clear
		border "Add Entry to /etc/hosts"
		echo
		optionfive
		;;

## 6. Quitting
		
		6|six|SIX)
		
		echo
		echo "Quitting..."
		echo
		sleep 0.7
		;;

## Invalid selection
		
		*)
		
		echo
		echo "${R}Invalid selection{$D}."
		sleep 0.7
		;;
	
	esac
done
