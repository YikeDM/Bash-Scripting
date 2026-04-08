while true; do
OPTION1=$(whiptail --title "OpenWRT Helpdesk Menu" --menu "   Welcome to the Helpdesk menu.\n        \
 Choose an option" 25 38 9 \
"Proceed" "" \
"Exit" "" 3>&1 1>&2 2>&3)

# Option menu with whiptail to ensure the user wishes to proceed

if [ "$OPTION1" = "Proceed" ]; then
        :
else
        exit 0
fi

# Short IF statement, to confirm the choice

OPTION2=$(whiptail --title "Command Selection" --menu "Choose an option" 25 78 16 \
"INT" "Display Available Interfaces" \
"SEL" "Select Interface to display IP and MAC Address Information" \
"UPT" "Display Router Uptime" \
"DSK" "Display Disk Usage and CPU Utilisation" \
"RST" "Restart Network Service" \
"NMP" "Run Nmap Scan (-F) on IP Address" \
"FWZ" "Display Firewall Zones" \
"RBT" "Reboot the Router" 3>&1 1>&2 2>&3)

# Large menu displaying available options.

if [ "$OPTION2" = "INT" ]; then
        INTINFO=$(ip a | grep UP,LOWER_UP | awk '{print $2}' | sed 's/://g')

        whiptail --title "INT Output" --msgbox "$INTINFO" 15 25 16 3>&1 1>&2 2>&3

# Queries interface which are in the UP state, prints the interface ID, and removes the trailing colon.
# Implemented into a whiptail message box

elif [ "$OPTION2" = "SEL" ]; then
        MENU_STRING=""
        AVINT=$(ip a | grep UP,LOWER_UP | awk '{print $2}' | sed 's/://g')
        for i in $AVINT; do
                MENU_STRING="$MENU_STRING $i "Interface""
        done

        # Select IP by creating the options by concatenating a string ( whiptail requires ID and message)

        USRINT=$(whiptail --title "Interface Selection" --menu "                  Select an Interface" 20 60 5 \
        $MENU_STRING 3>&1 1>&2 2>&3)

        # Creates whiptail menu to display options

        IP_INFO=$(ip a show $USRINT | grep -e "inet" -e "link" | awk '{print $2}')
        MAC=$(echo $IP_INFO | awk '{print $1}')
        IPv4=$(echo $IP_INFO | awk '{print $2}')
        IPv6=$(echo $IP_INFO | awk '{print $3}')
        whiptail --title "$USRINT IP and MAC Information" --msgbox "MAC: $MAC\nIPv4: $IPv4\nIPv6: $IPv6" \
        15 45 16 3>&1 1>&2 2>&3

        # Acquires IP information, gathers inet(IP) and link(MAC) information, and gathers the required
        # information inside three separate variables, implemented inside a whiptail message box

elif [ "$OPTION2" = "UPT" ]; then
        UPT=$(uptime -p | sed 's/up//g')

        whiptail --title "Host Uptime" --msgbox "Uptime: $UPT" 15 45 16 3>&1 1>&2 2>&3

        # Acquired uptime updated package, with -p provides "up x days y hours z minutes"
        # Implemented inside a whiptail message box
        
elif [ "$OPTION2" = "DSK" ]; then
        DSK=$(df -h | awk '{printf "%-15s %-8s %-8s %-8s\n", $1, $2, $3, $4}')
        CPU=$(top -n 1 | grep CPU: | awk '{print $1 " " $2}' | grep CPU | awk '{print $2}')

        # Acquire disk utilisation with df-h, gathering filesystem information and formatting with printf
        # Further acquriing CPU usage with top -n 1 and manipulating the output to recieve the percentage

        whiptail --title "Disk Utilisation and CPU Usage" --msgbox \
        "Disk Usage: \n$DSK \n\n\nCPU Usage: $CPU" 20 60 5 3>&1 1>&2 2>&3

        # Implemented inside a whiptail message box

elif [ "$OPTION2" = "RST" ]; then
        RESPONSE=$(whiptail --title "Confirmation" --menu "                     Are you sure?" 20 60 5 \
        "Yes" " " \
        "No" " " 3>&1 1>&2 2>&3)

        # Ensure the user wishes to perform this action, as it may cause network downtime.

        if [ "$RESPONSE" = "Yes" ]; then
                nohup service network restart >/dev/null 2>&1 &
                {
                        for i in $(seq 0 20 100); do
                                sleep 1
                                echo $i
                        done
                } | whiptail --title "Network Restart" --gauge "Applying changes and restarting interfaces..." 10 60 0
                STATUS=$(service network status)

                # Restart the service and pipe a for loop inside whiptail to provide loading bar functionality

                if [ "$STATUS" = "running" ]; then
                        whiptail --title "Network Service Restart" --msgbox \
                        "Restart Successful\nService Status: $STATUS" 15 45 16 3>&1 1>&2 2>&3

                else
                        whiptail --title "Network Service Restart" --msgbox \
                        "Restart Unsuccessful,\nService Status: $STATUS" 15 45 16 3>&1 1>&2 2>&3

                fi

                # Create IF statement using service network status, ensuring the service successfully restarts.
        fi

elif [ "$OPTION2" = "NMP" ]; then
        USRIPADDR=$(whiptail --inputbox "IP Address:" 25 78 \
        --title "Enter IP Address to scan" 3>&1 1>&2 2>&3)

        # whiptail input box for user to provide IP address to scan

        nmap -F 127.0.0.1 > /tmp/nmap_scan 2>&1 &
        {
                for i in $(seq 0 15 100); do
                        sleep 1
                        echo $i
                done
        } | whiptail --title "Nmap Scan" --gauge "Scanning target IP address..." 10 60 0
        OUTPUT=$(cat /tmp/nmap_scan)
        whiptail --title "$USRIPADDR Scan Results" --msgbox "$OUTPUT" 25 78 3>&1 1>&2 2>&3

        # Similar to the network restart, create a loading bar for Nmap scan giving time to perform this scan
        # further outputting the Nmap scan to a file to allow for seamless presentation with whiptail

elif [ "$OPTION2" = "FWZ" ]; then
        FWZONE=$(grep -E "option output|option input|option forward|option network|config zone|list   network" \
        /etc/config/firewall | tail -n +4)
        # tail implemented due to defaults appearing in output.
        FWZONE=$(grep -E "option output|option input|option forward|option network|config zone|list   network" \
        /etc/config/firewall | tail -n +4)
        # tail implemented due to defaults appearing in output.

        # Acquird firewall information using multiple OR commands within grep, providing the required networking
        # information, was implemented with trial and error, as the file contains numerous details

        whiptail --title "Firewall Zones" --msgbox "Firewall Zones:\n$FWZONE" 25 78 3>&1 1>&2 2>&3

        # Firewall zones displayed in a whiptail messsage box

elif [ "$OPTION2" = "RBT" ]; then
        RBTRESPONSE=$(whiptail --title "Confirmation" --menu "             Are you sure you wish to restart?" 20 60 5 \
        "Yes" " " \
        "No" " " 3>&1 1>&2 2>&3)

        # Whiptail prompt to ensure the user truly wishes to restart the server

        if [ "$RBTRESPONSE" = "Yes" ]; then
                {
                        for i in $(seq 0 15 100); do
                                sleep 1
                                echo $i
                        done
                } | whiptail --title "Restarting Router" --gauge "Restarting...." 10 60 0
                reboot now >/dev/null 2>&1



        fi
fi

done

# While loop acquired to ensure seamless usage
