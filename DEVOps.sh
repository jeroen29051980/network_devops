#! /bin/bash

echo '
*********************************
*        DEVOPS PROJECT         *
*      NEXTCLOUD ON DOCKER      *
*      ===================      *
*                               *
*    Automatische Installatie   *
*********************************
'

echo "Dit script dient als root-gebruiker uitgevoerd te worden:"
sudo echo "script kan verder gaan ..."

echo '
Controleren op noodzakelijke toepassingen ...
'
sleep 3

sudo apt-get install git ansible -y > /dev/null &

PID=$! #Get process ID from latest command

echo -e " Even geduld dit kan even duren... \n Alle noodzakelijke toepassingen worden nu geïnstalleerd \n"
printf "Voortgang > "
# While process is running...
while kill -0 $PID 2> /dev/null; do 
    printf  "▓"
    sleep 1
done
printf " > Klaar! \n"

#check if terraform was installed
check_terraform () {
    command
    if [ -command $(which terraform) = "/snap/bin/terraform" ]; then
        return '1'
    fi
}


if [ -v check_terraform ]; then
    echo "Terraform wordt geïnstalleerd"
    sudo snap install terraform --classic
fi

DIRECTORY=/home/$USER/DEVOPS_PROJ

{ if [ -d "$DIRECTORY" ]; then
  rm -rf /home/$USER/DEVOPS_PROJ/
  git clone https://github.com/jeroen29051980/DEVOPS_PROJ.git /home/$USER/DEVOPS_PROJ
fi

if [ ! -d "$DIRECTORY" ]; then
  git clone https://github.com/jeroen29051980/DEVOPS_PROJ.git /home/$USER/DEVOPS_PROJ
fi } &> /dev/null

echo -e "Het script gaat nu verder met het opzetten van de virtuele machines \n"
echo "Opgelet: Momenteel werkt dit script enkel met 
