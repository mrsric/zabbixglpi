# zabbixglpi

Objetivo: Integrar Triggers do ZABBIX 2.4 com o GLPI 0.91.

Trigger de Status PROBLEM abrem chamados no GLPI

Trigger de Status OK fecham os chamados que contem a TriggerID gerada na abertura e que estão com o status de "Processando (atribuído)"

Edite o arquivo zabbix_glpi_ticket.sh
```
# Authentication
username="glpi"
password="glpiglpi"
urlGlpi="http://host/glpi"
```

Usage: 
```sh
$ ./zabbix_glpi_ticket.sh <PROBLEM|OK> <PARAMETERS>"
```

EX PROBLEM:
```sh
$ ./zabbix_glpi_ticket.sh "PROBLEM" "TITLE" "DESCRIPTION" "CATEGORY" "TYPE CONNECTION: EX Printer" "ID ITEM"
```

EX OK:
```sh
$ ./zabbix_glpi_ticket.sh "OK" "TRIGGER ID" "SOLUTION"
```
