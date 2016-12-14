# zabbixglpi

### Objetivo: 

Integrar Triggers do ZABBIX 2.4 com o GLPI 0.91.

 - Trigger de Status PROBLEM abrem chamados no GLPI

 - Trigger de Status OK fecham os chamados que contem a TriggerID gerada na abertura e que estão com o status de "Processando (atribuído)"

### Configuração: 
Edite o arquivo zabbix_glpi_ticket.sh
```
# Authentication
username="glpi"
password="glpiglpi"
urlGlpi="http://host/glpi"
```

#### Uso: 
```sh
$ ./zabbix_glpi_ticket.sh <PROBLEM|OK> <PARAMETERS>"
```

Ex. PROBLEM:
```sh
$ ./zabbix_glpi_ticket.sh "PROBLEM" "TITLE" "DESCRIPTION" "CATEGORY" "TYPE CONNECTION: EX Printer" "ID ITEM"
```

Ex. OK:
```sh
$ ./zabbix_glpi_ticket.sh "OK" "TRIGGER ID" "SOLUTION"
```

### Configuração GLPI: 

Habilite a API Rest no GLPI pelo caminho:

```
Configurar -> Geral -> API
    * Habilitar API Rest: SIM
    * Habilitar login com credenciais: SIM
```
Adicione um novo cliente de API, conforme necessario:

```
Configurar -> Geral -> API -> Adicionar cliente de API
    * Nome: "Nome para o cliente"
    * Ativo: SIM
    * Registrar log de conexões: LOGS
    * Filtrar acesso: (Deixe esses parâmetros vazios para desabilitar a restrição de acesso à API ou restrinja conforme necessario. Se regerado Token da aplicação, altere o script com o app_token gerado)
```


#### Referências:
https://github.com/glpi-project/glpi/blob/master/apirest.md
