#!/bin/bash

#Help Menu
function help_menu()
{
        echo "
█░█ █▀█ █▄░█   █▀ ▀█▀ ▄▀█ █▀█ ▀█▀ █▀▀ █▀█
▀▄▀ █▀▀ █░▀█   ▄█ ░█░ █▀█ █▀▄ ░█░ ██▄ █▀▄
Created By: @Cone_Virus

./vpnstarter.sh <Options>

--Options--
-q <openvpn file> : Quickstart with given file
-w                : Runs only Interface Watcher
-m                : Runs menu for VPN/ directory"
exit 0
}

#Closing the VPN connection
function closing_connection()
{
        echo " Shutting Down"
        sudo killall openvpn 2>/dev/null #Close openvpn connections
        exit 0 #Close program
}

#VPN Selection Menu
function menu()
{
        vpnpacks=$(ls VPN/ | sed -n "s/\(.*\).ovpn/\1/p") #Get openvpn file names

        #Loop for selection menu
        while :
        do
                count=1
                echo "Please select which VPN connection to start"
                for i in $vpnpacks
                do
                        printf "%d) %s\n" "$count" "$i"
                        count=$(($count + 1))
                done
                read -p "Choice: " option

                if [ "0" -lt "$option" ] && [ "$(($count - 1))" -ge "$option" ]
                then
                        break
                else
                        echo "Invalid Choice"
                        echo ""
                fi
        done

        #Starting the connection
        choice=$(echo $vpnpacks | cut -d " " -f "$option")
        pack=$(echo "$choice.ovpn")
        choice="Connection for $choice"
        echo "Starting VPN connection..."
        sudo openvpn "VPN/$pack" > /dev/null 2>&1 & 

}

#Quickstarter
function quickstart()
{
        file=$1
        if [[ "$file" == *".ovpn" ]]
        then
                if [ -f $file ]
                then
                        #Starting the connection
                        choice=$(echo $file | sed -n "s/.*\/\(.*\).ovpn/\1/p")
                        choice="Connection for $choice"
                        echo "Starting VPN connection..."
                        sudo openvpn "$file" > /dev/null 2>&1 & 
                else
                        echo "File does not exist"
                        help_menu
                fi
        else
                echo "File does not end with .ovpn"
                help_menu
        fi
}

#Interface Watcher
function interwatcher()
{
        echo "Starting Interface Watcher..."
        while :
        do
                sleep 20
                clear
                echo ""
                echo "$choice"
                echo "---------------------------"
                total=$(ls -A /sys/class/net | wc -l) #Total interfaces
                watcher=$(sudo ifconfig | grep -w inet -B 1) #Ifconfig to mess with
                inter=$(echo "$watcher" | sed -n "s/\(.*\):/\1/p" | awk '{ print $1 }' | sed ':a;N;$!ba;s/\n/ /g') #Interfaces to a better format
                ip=$(echo "$watcher" | sed -n "s/inet \(.*\) /\1/p" | awk '{ print $1 }' | sed ':a;N;$!ba;s/\n/ /g') #IP of interfaces in a better format
                for ((i=0;i<$total;i++))
                do
                        tempinter=$(echo "$inter" | cut -d " " -f $(($i + 1)))
                        tempip=$(echo "$ip" | cut -d " " -f $(($i + 1)))
                        printf "%-6s:%20s\n" "$tempinter" "$tempip" #Printing in format
                done
                echo "---------------------------"
        done
}

#Trap SIGINT
trap closing_connection SIGINT

#Main program
if [[ $# == 0 || "$1" == "-h" ]]
then
        help_menu
elif [[ "$1" == "-m" ]]
then
        menu
        interwatcher
elif [[ "$1" == "-w" ]]
then
        choice="Interface Watcher"
        interwatcher
elif [[ "$1" == "-q" ]]
then
        quickstart $2
        interwatcher
else
        help_menu
fi
