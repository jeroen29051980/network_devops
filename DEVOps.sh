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

if [ -f "$OCI" ];
then
  echo "Geef de user-ID (OCI_ID): "
  read OCI_user_input
  export OCI_user_input
  echo -e " \n Geef de tenant-ID (OCI_ID): "
  read OCI_tenant_input
  export OCI_tenant_input
  echo -e " \n Geef de fingerprint-ID: "
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

echo "De benodigde virtuele machines zullen nu aangemaakt worden op basis van je ingebrachte gegevens"
envsubst </home/$USER/DEVOPS_PROJ/files/vm1.tf >/home/$USER/DEVOPS_PROJ/wip.tf
terraform init 2> home/$USER/DEVOPS_PROJ/logs/TF_init_err.txt
terraform plan 2> home/$USER/DEVOPS_PROJ/logs/TF_plan_err.txt
terraform apply 2> home/$USER/DEVOPS_PROJ/logs/TF_apply_err$(( counter+=1 )).txt
rm wip.tf
envsubst </home/$USER/DEVOPS_PROJ/files/vm2.tf >/home/$USER/DEVOPS_PROJ/wip.tf
terraform apply 2> home/$USER/DEVOPS_PROJ/logs/TF_apply_err$(( counter+=1 )).txt
rm wip.tf
envsubst </home/$USER/DEVOPS_PROJ/files/vm3.tf >/home/$USER/DEVOPS_PROJ/wip.tf
terraform apply 2> home/$USER/DEVOPS_PROJ/logs/TF_apply_err$(( counter+=1 )).txt
rm wip.tf

