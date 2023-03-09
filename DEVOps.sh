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

PID=$! #simulate a long process

echo -e " Even geduld dit kan even duren... \n Alle noodzakelijke toepassingen worden nu geïnstalleerd \n"
printf "Voortgang > "
# While process is running...
while kill -0 $PID 2> /dev/null; do 
    printf  "▓"
    sleep 1
done
printf " > Klaar! \n"


DIRECTORY=/home/$USER/DEVOPS_PROJ

{ if [ -d "$DIRECTORY" ]; then
  rm -rf /home/$USER/DEVOPS_PROJ/
  git clone https://github.com/jeroen29051980/DEVOPS_PROJ.git /home/$USER/DEVOPS_PROJ
fi

if [ ! -d "$DIRECTORY" ]; then
  git clone https://github.com/jeroen29051980/DEVOPS_PROJ.git /home/$USER/DEVOPS_PROJ
fi } &> /dev/null
