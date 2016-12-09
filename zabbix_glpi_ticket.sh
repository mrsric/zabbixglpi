#!/bin/bash
# GLPI - API REST (Integration with Trigger Zabbix)
# By Marcos Ricardo de Souza
# Emplasa 05/12/2016 version 1.0

# Authentication
username="glpi"
password="glpiglpi"
urlGlpi="http://host/glpi"

# Ticket Parameters (Problem)
ticketTitle="$2"
ticketContent="$3"
ticketCategory="$4" #143# - Impressora Corporativa-> Ressuprimento
ticketItemType="$5" #Printer# - Item Type 
ticketItemID="$6"
ticketDate=`date +"%Y-%m-%d %R:%S"`

# Ticket Parameters (OK)
triggerID="$2"
ticketSolution="$3"

# Base URL API.
site_url="$urlGlpi/apirest.php"

# Endpoint URL for login action.
login_url="$site_url/initSession"


dishelp() {
                echo "**************************************************************************************"
                echo "*                       SCRIPT TICKETS GLPI MANAGEMENT	                           *"
                echo "*                      Create by Marcos Ricardo de Souza                             *"
                echo "**************************************************************************************"
                echo
		echo "Usage: $0 <PROBLEM|OK> <PARAMETERS>"
		echo " "
                echo "EX PROBLEM:"
		echo $0' "PROBLEM" "TITLE" "DESCRIPTION" "CATEGORY" "TYPE CONNECTION: EX Printer" "ID ITEM"'
		echo " "
                echo "EX OK:"
		echo $0' "OK" "TRIGGER ID" "SOLUTION"'
		echo " "
                exit 3
}

createToken() {
				# Create Token
				sessiontoken=`curl --user $username:$password -X GET \
				-H 'Content-Type: application/json' \
				-H "App_Token: f7g3csp8mgatg5ebc5elnazakw20i9fyev1qopya7" \
				"$site_url/initSession"`
				token=`echo $sessiontoken | cut -d'"' -f4`
}

killToken() {
				# Kill Token
				killtoken=`curl -X GET \
				-H 'Content-Type: application/json' \
				-H "Session-Token: $token" \
				-H "App_Token: f7g3csp8mgatg5ebc5elnazakw20i9fyev1qopya7" \
				"$site_url/killSession"`
}

typeEvent=`echo "$1" | tr '[:lower:]' '[:upper:]'`

case "$typeEvent" in
        PROBLEM)
				if [ $# -lt 4 ] || [ $# -gt 6 ] ; then
				dishelp
				fi

				createToken

				# Create Ticket
				ticketContent=`echo $ticketContent | awk '{printf("%s", $0 (NR==1 ? "\\\n" : "\\\n"))}'`
				data='{"input": {"name": "'$ticketTitle'", "content": "'$ticketContent'", "itilcategories_id": '$ticketCategory'}}'
				ticket=`curl -X POST \
				-H 'Content-Type: application/json' \
				-H "Session-Token: $token" \
				-H "App_Token: f7g3csp8mgatg5ebc5elnazakw20i9fyev1qopya7" \
				-d "$data" \
				"$site_url/Ticket/"`
				idTicket=`echo $ticket | cut -d':' -f2 | cut -d'}' -f1`

				# Associate Item
				data='{"input": {"itemtype": "'$ticketItemType'", "items_id": '$ticketItemID', "tickets_id": '$idTicket'}}'
				itemTicket=`curl -X POST \
				-H 'Content-Type: application/json' \
				-H "Session-Token: $token" \
				-H "App_Token: f7g3csp8mgatg5ebc5elnazakw20i9fyev1qopya7" \
				-d "$data" \
				"$site_url/Item_Ticket/"`

				killToken

				echo "Chamado: $idTicket"
		exit 0
		;;

		OK)
				if [ $# -lt 3 ] || [ $# -gt 3 ] ; then
				dishelp
				fi

				createToken

				# Return Ticket ID - Search by Trigger ID
				query='criteria\[0\]\[itemtype\]\=Ticket&criteria\[0\]\[field\]\=21&criteria\[0\]\[searchtype\]\=contains&criteria\[0\]\[value\]\=Trigger.ID:'$triggerID'&criteria\[1\]\[link\]\=AND&criteria\[1\]\[itemtype\]\=Ticket&criteria\[1\]\[field\]\=12&criteria\[1\]\[searchtype\]\=equals&criteria\[1\]\[value\]\=2'
				ticket=`curl -X GET \
				-H 'Content-Type: application/json' \
				-H "Session-Token: $token" \
				-H "AppToken: f7g3csp8mgatg5ebc5elnazakw20i9fyev1qopya7" \
				"$site_url/search/Ticket?\$query"`
				idTicket=`echo $ticket | cut -d":" -f7 | cut -d"," -f1`

				if [ -n "$idTicket" ];
				then

					# Close Ticket
					data='{"input": {"id": "'$idTicket'", "solution": "'$ticketSolution'"}}' 
					return=`curl -X PUT \
					-H 'Content-Type: application/json' \
					-H "Session-Token: $token" \
					-H "App_Token: f7g3csp8mgatg5ebc5elnazakw20i9fyev1qopya7" \
					-d "$data" \
					"$site_url/Ticket/"`
					return=`echo $return | cut -d'"' -f2`
					return="Chamado Atualizado: $return"

				else
					return="Chamado não encontrato"
				fi

				killToken

				echo "$return"


		exit 0
		;;

		 *)
				dishelp
esac
