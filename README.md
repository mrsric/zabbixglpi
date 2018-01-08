# zabbixglpi

### Objetivo: 

Integrar Triggers do ZABBIX 2.2.4 com o GLPI 9.1.6

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
    * Filtrar acesso: (Deixe esses parâmetros vazios para desabilitar a restrição
                       de acesso à API ou restrinja conforme necessario. Se regerado 
                       Token da aplicação, altere o script com o app_token gerado)
```

### Configuração Zabbix: 

Crie ações com as Condições necessarias e cofigure o Tipo de Operação Comando remoto:

Ex: Abrir Chamado - Impressora

```
Condições: 
     Valor da trigger = INCIDENTE
     Grupo de hosts = Impressoras
     
Ações: 
     Tipo da operação: Comando remoto
     Destino: Host: Zabbix server
     Tipo: Script personalizado
     Executar em: Agent Zabbix
     Comando: /etc/zabbix/scripts/zabbix_glpi_ticket.sh "{TRIGGER.STATUS}" "{TRIGGER.STATUS}: {TRIGGER.NAME} - {HOST.NAME}" "Equipamento: {HOST.NAME} \nAlerta: {TRIGGER.NAME} \nStatus: {TRIGGER.STATUS} \nSeveridade: {TRIGGER.SEVERITY} \n\nOriginal event ID: {EVENT.ID} \nTrigger.ID:{TRIGGER.ID} \n\n\nÚltimo Valor: \n{ITEM.LASTVALUE}" 143 "Printer" "{INVENTORY.TAG}"
```

Ex: Fechar Chamado - Impressora

```
Condições: 
     Valor da trigger = OK
     Grupo de hosts = Impressoras
     
Ações: 
     Tipo da operação: Comando remoto
     Destino: Host: Zabbix server
     Tipo: Script personalizado
     Executar em: Agent Zabbix
     Comando: /etc/zabbix/scripts/zabbix_glpi_ticket.sh "{TRIGGER.STATUS}" "{TRIGGER.ID}" "Evento ({TRIGGER.NAME}) normalizado \nChamado fechado pelo Zabbix. \n\n\nÚltimo Valor: \n{ITEM.LASTVALUE}"
```

#### Referências:
https://github.com/glpi-project/glpi/blob/master/apirest.md
