# DEVOPS_PROJ
DEVOPS Project Thomas More Campus Lier Avond

script kan gestart worden met onderstaande commando

Op voorwaarde dat git geïnstalleerd is op het host-systeem

> apt-get install git

> git clone https://github.com/jeroen29051980/DEVOPS_PROJ.git && bash ./DEVOPS_PROJ/DEVOps.sh

Voor de goede werking van dit script is het tevens noodzakelijk dat er een bestand bestaat in de root-folder van de gebruiker \n
met de naam OCI.pem.

Dit bestand dient de private sleutel te bevatten van Oracle Cloud.


Push naar deze repository gebeurt over het algemeen door de eigenaar.  Inhoudelijk blijft dit echter een groepswerk.

Er werden reeds een aantal playbooks (blanco) aangemaakt en geüpload naar GIT

    - Playbooks aangemaakt door Ann werden geüpload op 29/04/2023
        -  zouden gebruikt kunnen worden met een manuele installatie van nextcloud.

        - Er is echter geopteerd om te werken met een docker-uitrol voor de nextcloud-instantie

Voor wat betreft de one-click deployment werd reeds een begin gemaakt met:

Root-privileges gegeven door de gebruiker

    - Met het oog op installeren van ontbrekende pakketten op de hostmachine

Een check van de geïnstalleerde pakketten op de host-machine

    - Terraform werd geïnstalleerd bij wijze van snap-pakket (bij navraag aan de docent zorgt dit niet voor extra problemen)

Een propere download van de GIT-repository (erase and pull)

DONE: opzetten van ansible-configuratie op de host-machine met remote configuratiebestanden voor HOSTS en CONF

    - Wordt verwezenlijkt door 'provisioner' in Terraform script

TESTING: opzetten VM'S op Oracle Cloud met terraform en eventuele HA voor 2 machines met Nextcloud

    - Terraform-script voor het opzetten van 3 VM's werd gemaakt aan de van de documentatie van de docent.

    - Testing wordt momenteel uitgevoerd (29/04/2023) > succesvolle test met hardcoded variabelen

    Laatste wijzigingen werden gepushed onder commentaar "Testing Hardcoded final"

IN PROGRESS: configureren van de playbooks - centralisatie gebeurt in install.yaml waar alle playbooks worden aangeroepen.

NOT NESCESSARY: aanmaken van de diverse configuratiebestanden voor verschillende toepassingen op de client-machines

Toegevoegd in terraform script: host_key_checking=false > Dit vermijd dat er tijdens de initiële uitvoering van het Ansible een

vertraging voorkomt voor een authenticatiecheck van de client-machine