#!/bin/bash

############################
# 	sshsetup v1.4      #
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

## Remote host variables list - non whiptail

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

### Option Functions - non whiptail

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

### Option Functions - whiptail

# Option 1 - whiptail

optiononewhip () {
if (whiptail --title "Install/Upgrade OpenSSH-Server" --yesno "Install or upgrade the openssh-server package?\n\nNOTE: You may need to provide your password to the terminal as sudo apt-get requires root permission." 10 78); then
    sudo apt-get install openssh-server
    echo
else
    :
fi
}

# Option 2 - whiptail

optiontwowhip () {
INPUTPORT=
INPUTIP=
INPUTUSER=
INPUTHOST=

#Port
while [[ "$INPUTPORT" = "" ]] || [[ ! "$INPUTPORT" =~ ^-?[0-9]+$ ]];
do
	INPUTPORT=$(whiptail --inputbox "Enter remote host's SSH port:" 8 78 --nocancel --title "Remote Host Variables" 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
    
       	if [ "$INPUTPORT" = "" ] || [[ ! "$INPUTPORT" =~ ^-?[0-9]+$ ]];
		then	
    		whiptail --title "Error" --msgbox "Please only enter numbers." 8 78
    	else
    		PORTVAR=${INPUTPORT}
    		echo "Port=${PORTVAR}"
		fi
	
	else
	    :
	fi
done

#IP
while [[ "$INPUTIP" = "" ]] || [[ ! "$INPUTIP" =~ ^-?[0-9.]+$ ]];
do 
	INPUTIP=$(whiptail --inputbox "Enter remote host's IP address:" 8 78 --nocancel --title "Remote Host Variables" 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
    	
    	if [ "$INPUTIP" = "" ] || [[ ! "$INPUTIP" =~ ^-?[0-9.]+$ ]];
		then	
    		whiptail --title "Error" --msgbox "Please enter an ip (x.x.x.x)" 8 78
    	else
    		IPVAR=${INPUTIP}
    		echo "IP=${IPVAR}"
		fi
    
    else
    	:
	fi
done

#Username
while [[ "$INPUTUSER" = "" ]] || [[ "$INPUTUSER" = *[[:space:]]* ]];
do
	INPUTUSER=$(whiptail --inputbox "Enter remote host's Username:" 8 78 --nocancel --title "Remote Host Variables" 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
    
       	if [ "$INPUTUSER" = "" ] || [[ "$INPUTUSER" = *[[:space:]]* ]];
		then	
    		whiptail --title "Error" --msgbox "Please enter a username without spaces." 8 78
    	else
    		USERVAR=${INPUTUSER}
    		echo "User=${USERVAR}"
		fi
	
	else
	    :
	fi
done

#Hostname
while [[ "$INPUTHOST" = "" ]] || [[ "$INPUTHOST" = *[[:space:]]* ]];
do
	INPUTHOST=$(whiptail --inputbox "Enter remote host's Hostname:" 8 78 --nocancel --title "Remote Host Variables" 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
    
       	if [ "$INPUTHOST" = "" ] || [[ "$INPUTHOST" = *[[:space:]]* ]];
		then	
    		whiptail --title "Error" --msgbox "Please enter a hostname without spaces." 8 78
    	else
    		HOSTVAR=${INPUTHOST}
    		echo "Hostname=${HOSTVAR}"
    		echo
		fi
	
	else
	    :
	fi
done
}

# Option 3 - whiptail

optionthreewhip () {
if [ ! -d "$HOME"/.ssh ];
then
	if (whiptail --title "Create ${HOME}/.ssh?" --yesno "$HOME/.ssh does not exist. Create it now?" 8 78);
	then
   		mkdir "$HOME"/.ssh
   		if [ "$?" = 0 ];
   		then
			whiptail --title "Create ${HOME}/.ssh?" --msgbox "Created! Continuing" 8 78
   			echo "${HOME}/.ssh ${G}created${D}!"
   			echo
   		else
			whiptail --title "Failure!" --msgbox "Could not create ${HOME}/.ssh. Please check your user permissions." 8 78
   			echo "${HOME}/.ssh creation ${R}failed${D}! Please check your user permissions."
   			echo
   		fi	
   	else
		whiptail --title "$HOME/.ssh" --msgbox "Not creating. This tool requires ${HOME}/.ssh exists." 8 78
		echo "${HOME}/.ssh ${R}doesn't exist${D}, and ${R}isn't${D} being created by user request."
		echo
	fi
fi	

if [ -d "$HOME"/.ssh ];
then
	cd "$HOME"/.ssh
	if [ -z ${PORTVAR+x} ] && [ -z ${IPVAR+x} ] && [ -z ${USERVAR+x} ] && [ -z ${HOSTVAR+x} ];
	then
		whiptail --title "No Variables Set" --msgbox "Please set remote host variables before running this option." 8 78
	else
		if (whiptail --title "Create SSH Keys" --yesno "Create the following SSH keys?\n\n$HOME/.ssh/$HOSTVAR\n$HOME/.ssh/$HOSTVAR.pub\n\nIf they already exist, you'll need to respond 'y' or 'n' to overwrite them." 13 78); then
   			ssh-keygen -f "$HOSTVAR" -q -N ""
   			echo
   			if [ -e "$HOME"/.ssh/"$HOSTVAR".pub ] && [ -e "$HOME"/.ssh/"$HOSTVAR" ];
   			then
   				printf "${G}SSH keys created successfully${D}:\n%s/.ssh/%s (private)\n%s/.ssh/%s.pub (public)\n" "$HOME" "$HOSTVAR" "$HOME" "$HOSTVAR"
   				echo
   				if (whiptail --title "Transfer" --yesno "Transfer $HOME/.ssh/$HOSTVAR.pub to $USERVAR@$IPVAR on port $PORTVAR?\n\nYou'll need to respond yes to the fingerprint prompt, and provide $USERVAR's password on $IPVAR to the terminal." 12 78); then
   				ssh-copy-id -i "$HOSTVAR".pub -p "$PORTVAR" "$USERVAR"@"$IPVAR"
   					if [ "$?" = 0 ];
   					then
   						printf "${G}SSH keys transferred successfully${D}:\n%s/.ssh/%s.pub to %s@%s on port %s\n" "$HOME" "$HOSTVAR" "$USERVAR" "$IPVAR" "$PORTVAR"
   						echo
   						whiptail --title "Success!" --msgbox "Keys successfully transfered!\n\nPlease run the SSH Config File option to enable passwordless login." 10 78
					else
						whiptail --title "Failure!" --msgbox "SSH key transfer failed. Please check your variables and/or password." 10 78
						echo "${R}SSH key transfer failed${D}. Please check your variables and/or password."
						echo
					fi	
   				fi
   			else
				whiptail --title "Failure!" --msgbox "SSH key creation failed. Please check your variables and/or permissions." 10 78
   				echo "${R}SSH key creation failed${D}. Please check your variables and/or permissions"
   				echo
    		fi
    	else
			whiptail --title "Create SSH Keys" --msgbox "Not creating. This options requires SSH keys be created." 8 78
			echo "${R}${HOME}SSH keys not created${D} by user request. This option requires SSH keys be created."
			echo
		fi
   	fi
fi
}

# Option 4 - whiptail

optionfourwhip () {
if [ -z ${PORTVAR+x} ] && [ -z ${IPVAR+x} ] && [ -z ${USERVAR+x} ] && [ -z ${HOSTVAR+x} ];
then
	whiptail --title "No Variables Set" --msgbox "Please set remote host variables before running this option." 8 78
else
	CONFIGVAR="$HOME"/.ssh/config
	if [ ! -e ${CONFIGVAR} ];
	then
		whiptail --title "$HOME/.ssh/config" --msgbox "${CONFIGVAR} does not exist. Creating it now and continuing." 8 78
		touch "$HOME"/.ssh/config
		echo "${CONFIGVAR} ${R}doesn't exist${D}. ${G}Created${D}!"
		echo
	fi
	CONFIGENTRYWHIP=$(printf "\nHost    %s\n\tHostname %s\n\tUser %s\n\tPort %s\n\tIdentityFile %s/.ssh/%s\n" "$HOSTVAR" "$IPVAR" "$USERVAR" "$PORTVAR" "$HOME" "$HOSTVAR")
	if (whiptail --title "$HOME/.ssh/config" --yesno "Add the following entry to $CONFIGVAR?\n\n$CONFIGENTRYWHIP" 15 78);
	then
		whiptail --title "$HOME/.ssh/config" --msgbox "Backing up config to config.bak first, then adding the entry." 8 78
		cp "$HOME"/.ssh/config "$HOME"/.ssh/config.bak
		if [ "$?" = 0 ];
		then
			echo "${G}${CONFIGVAR}${D} backed up to ${G}${CONFIGVAR}.bak${D}"
			echo
			whiptail --title "$HOME/.ssh/config" --msgbox "Backup complete! Now we'll add the entry..." 8 78
			printf "\nHost\t%s\n\tHostname %s\n\tUser %s\n\tPort %s\n\tIdentityFile %s/.ssh/%s\n" "$HOSTVAR" "$IPVAR" "$USERVAR" "$PORTVAR" "$HOME" "$HOSTVAR" >> "$CONFIGVAR"
			if [ "$?" = 0 ];
			then
				whiptail --title "$HOME/.ssh/config" --msgbox "Entry added! You can now use 'ssh ${HOSTVAR}' to login without a password on ${IPVAR}" 9 78
				echo "The following entry was ${G}added${D} to ${CONFIGVAR}:"
				printf "\nHost\t%s\n\tHostname %s\n\tUser %s\n\tPort %s\n\tIdentityFile %s/.ssh/%s\n" "$HOSTVAR" "$IPVAR" "$USERVAR" "$PORTVAR" "$HOME" "$HOSTVAR"
				echo
			else
				whiptail --title "$HOME/.ssh/config" --msgbox "Could not add entry to ${CONFIGVAR}. check that it's owned by $USER." 8 78
				echo "${R}Could not${D} add entry to ${CONFIGVAR}. Please check its permissions."
				echo
			fi	
		else
			whiptail --title "$HOME/.ssh/config" --msgbox "Backup of ${CONFIGVAR} failed. check that it's owned by $USER." 8 78
			echo "Backup of ${CONFIGVAR} ${R}failed${D}. Please check its permissions."
			echo
		fi
	else
		whiptail --title "$HOME/.ssh/config" --msgbox "Not adding. Add an entry to ${CONFIGVAR} if you want passwordless login via SSH keys." 10 78
		echo "${R}Entry not added to ${CONFIGVAR}${D} by user request."
		echo
	fi	
fi	
}

# Option 5 - whiptail

optionfivewhip () {
if [ -z ${PORTVAR+x} ] && [ -z ${IPVAR+x} ] && [ -z ${USERVAR+x} ] && [ -z ${HOSTVAR+x} ];
then
	whiptail --title "No Variables Set" --msgbox "Please set remote host variables before running this option." 8 78
else
	HOSTFILEVAR=/etc/hosts
	if (whiptail --title "/etc/hosts" --yesno "Add the following entry to $CONFIGVAR?\n\n$IPVAR $HOSTVAR" 10 78);
	then
		whiptail --title "/etc/hosts" --msgbox "Backing up ${HOSTFILEVAR} to ${HOSTFILEVAR}.bak first, then adding the entry.\n\nNOTE: You'll need to provide your password to the terminal as /etc/hosts belongs to root." 12 78
		sudo cp /etc/hosts /etc/hosts.bak
		if [ "$?" = 0 ];
		then
			echo "${G}${HOSTFILEVAR}${D} backed up to ${G}${HOSTFILEVAR}.bak${D}"
			echo
			whiptail --title "/etc/hosts" --msgbox "Backup complete! Now we'll add the entry..." 8 78
			echo "$IPVAR" "$HOSTVAR" | sudo tee -a /etc/hosts >/dev/null
			if [ "$?" = 0 ];
			then
				whiptail --title "/etc/hosts" --msgbox "Entry added! You can now type ${HOSTVAR} instead of ${IPVAR} where necessary." 9 78
				echo "The following entry was ${G}added${D} to ${HOSTFILEVAR}:"
				echo "${IPVAR} ${HOSTVAR}"
				echo
			else
				whiptail --title "/etc/hosts" --msgbox "Could not add entry to ${HOSTFILEVAR}. Did you provide the correct password?" 8 78
				echo "${R}Could not${D} add entry to ${HOSTFILEVAR}. Check your password."
				echo
			fi	
		else
			whiptail --title "/etc/hosts" --msgbox "Backup of ${HOSTFILEVAR} failed. Did you provide the correct password?" 8 78
			echo "Backup of ${CONFIGVAR} ${R}failed${D}. Check your password?"
			echo
		fi
	else
		whiptail --title "/etc/hosts" --msgbox "Not adding. Add an entry to ${HOSTFILEVAR} if you want to use ${HOSTVAR} instead of ${IPVAR} where necessary." 10 78
		echo "${R}Entry not added to ${HOSTFILEVAR}${D} by user request."
		echo
	fi	
fi	
}

# Option 6 - whiptail

optionsixwhip () {
echo "${P}Goodbye${D}!"
}

  ############################
 #	     Main           #
############################

### macOS ###

if [[ $OSTYPE == darwin* ]];
then

	while [ "$ANS" != "6" ]; 
	do

		# Present main menu
		clear
		border "SSH Setup Tool - macOS"
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

### Linux ###

elif [[ $OSTYPE == linux* ]];
then

	dpkg-query -l whiptail >/dev/null 2>&1
	# If whiptail is installed
	if [ "$?" = "0" ];
	then

		while [ "$ANSWHIP" != "Exit" ] || [ "$ANSWHIP" = "1" ];
		do

			# Present main menu
			ANSWHIP=$(whiptail --title "SSH Setup Tool - Linux" --menu "Choose an option [Enter]" --nocancel 25 80 16 3>&1 1>&2 2>&3 \
			"OpenSSH-Server" "Install/Upgrade OpenSSH-Server package" \
			"Set Variables" "Set remote host Port, IP, Username, & Hostname" \
			"SSH Keys" "Setup & transfer SSH keys" \
			"SSH Config File" "Add remote host entry to ~/.ssh/config" \
			"Hosts File" "Add remote host entry to /etc/hosts" \
			"Exit" "Quit the program")
			case $ANSWHIP in

## 1. Install/Update openssh-server (sshd)		

				"OpenSSH-Server")
		
				optiononewhip
				;;

## 2. Configure remote host variables
		
				"Set Variables")
		
				optiontwowhip
				;;

## 3. Setup & send ssh keys to remote host
		
				"SSH Keys")
		
				optionthreewhip
				;;

## 4. Add remote host entry to ~/.ssh/config
			
				"SSH Config File")
		
				optionfourwhip
				;;

## 5. Add remote host entry to /etc/hosts
		
				"Hosts File")
		
				optionfivewhip
				;;

## 6. Quitting
		
				"Exit")
				
				optionsixwhip
				;;

## Invalid selection
		
				*)
				
				:		
				;;
	
			esac
		done

# If whiptail is NOT installed

	elif [ "$?" = "1" ];
	then

		while [ "$ANS" != "6" ]; 
		do

			# Present main menu
			clear
			border "SSH Setup Tool - Linux"
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

	fi

### Neither Linux or macOS
	
else
	echo "${C}OSTYPE${D} doesn't return Darwin or Linux. ${R}Exiting${D}..."
	sleep 0.7
fi
