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

if [ -command $(which terraform) != "/snap/bin/terraform" ]; then
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

echo -e " Het script gaat nu verder met het opzetten van de virtuele machines \n "
echo "Opgelet: Momenteel werkt dit script enkel met Oracle Cloud Infrastructure"

# Creatie tijdelijke ssh-sleutel voor gebruik tijdens script
# /tmp/sshkey en /tmp/sshkey.pub
ssh-keygen -b 2048 -t rsa -f /tmp/sshkey -q -N "" 

# Ingave door de gebruiker van de noodzakelijke gegevens voor de uitrol van de VM's op andere systemen
# De gebruiker dient tevens een bestand te voorzien op de home-folder met de naam OCI.pem
# Bestand is de private-sleutel voor verbinding met Oracle Cloud infrastructure

echo '
Geef hieronder de benodigde gegevens voor de verbinding met Oracle
Tevens is het nodig dat de private sleutel (OCI.pem) zich in de root van home bevindt 
**************************************************************************************
'
OCI=/home/$USER/OCI.pem

DIRECTORY2=/home/$USER/DEVOPS_PROJ/logs

{ if [ -d "$DIRECTORY2" ]; then
  rm -rf /home/$USER/DEVOPS_PROJ/logs/
  mkdir /home/$USER/DEVOPS_PROJ/logs/
  mkdir /home/$USER/DEVOPS_PROJ/files/KEYS/
fi

if [ ! -d "$DIRECTORY2" ]; then
  mkdir /home/$USER/DEVOPS_PROJ/logs/
  mkdir /home/$USER/DEVOPS_PROJ/files/KEYS/
fi } &> /dev/null

if [ -f "$OCI" ];
then
  echo "Geef de user-ID (OCI_ID): "
  read OCI_user_input
  export OCI_user_input
  echo -e "\n Geef de tenant-ID (OCI_ID): "
  read OCI_tenant_input
  export OCI_tenant_input
  echo -e "\n Geef de fingerprint-ID: "
  read OCI_fingerprint_input
  export OCI_fingerprint_input
  sudo cp /home/$USER/OCI.pem /home/$USER/DEVOPS_PROJ/files/KEYS/OCI.pem
else
  echo "Het benodigde bestand OCI.pem werkt niet"
  echo "Corrigeer de fout en herstart dit script met DEVOps.sh"
  exit 1 
fi

counter=0

# Terraform deploy voor de 3 VM naar Oracle Cloud Infrastructure

cd /home/$USER/DEVOPS_PROJ/

echo "De benodigde virtuele machines zullen nu aangemaakt worden op basis van je ingebrachte gegevens"
envsubst </home/$USER/DEVOPS_PROJ/main.tf >/home/$USER/DEVOPS_PROJ/main.tf
terraform init /home/$USER/DEVOPS_PROJ/main.tf #2> home/$USER/DEVOPS_PROJ/logs/TF_init_err.txt
terraform plan -out /home/$USER/DEVOPS_PROJ/plan.out #2> home/$USER/DEVOPS_PROJ/logs/TF_plan_err.txt
terraform apply /home/$USER/DEVOPS_PROJ/plan.out #> home/$USER/DEVOPS_PROJ/logs/TF_apply_err$(( counter+=1 )).txt

# Installatie playbook wordt aangeroepen via terraform
