# DEVOPS_PROJ
DEVOPS Project Thomas More Campus Lier Avond

Push naar deze repository gebeurt over het algemeen door de eigenaar.  Inhoudelijk blijft dit echter een groepswerk.

Er werden reeds een aantal playbooks (blanco) aangemaakt en geüpload naar GIT
    Playbooks aangemaakt door Ann werden geüpload op 29/04/2023
        > zouden gebruikt kunnen worden met een manuele installatie van nextcloud.
        > Er is echter geopteerd om te werken met een docker-uitrol voor de nextcloud-instantie

Voor wat betreft de one-click deployment werd reeds een begin gemaakt met:

Root-privileges gegeven door de gebruiker
    > Met het oog op installeren van ontbrekende pakketten op de hostmachine

Een check van de geïnstalleerde pakketten op de host-machine
    > Terraform werd geïnstalleerd bij wijze van snap-pakket (bij navraag aan de docent zorgt dit niet voor extra problemen)

Een propere download van de GIT-repository (erase and pull)

DONE: opzetten van ansible-configuratie op de host-machine met remote configuratiebestanden voor HOSTS en CONF
    Wordt verwezenlijkt door 'provisioner' in Terraform script

TD: opzetten VM'S op Oracle Cloud met terraform en eventuele HA voor 2 machines met Nextcloud
    Terraform-script voor het opzetten van 3 VM's werd gemaakt aan de van de documentatie van de docent.
    Testing wordt momenteel uitgevoerd (29/04/2023) > nog niet succesvol.

TD: configureren van de playbooks

TD: aanmaken van de diverse configuratiebestanden voor verschillende toepassingen op de client-machines


