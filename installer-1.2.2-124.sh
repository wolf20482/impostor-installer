#!/bin/bash
set -Eeuo pipefail
low_ram='262144' # 256MB
server_ram_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
cd ~
PrecompiledInstallation() {
    sudo apt-get update
    sudo apt-get install -y tar
    cd /usr/local
    mkdir impostor && cd impostor
    if [ "$arch" == 'x86_64' ];
    then
    wget https://ci.appveyor.com/api/buildjobs/1g7x9s6vkvr5wbqm/artifacts/build%2FImpostor-Server_1.2.2-ci.124_linux-x64.tar.gz
    tar -zxvf Impostor-Server_1.2.2-ci.124_linux-x64.tar.gz
    sudo chmod +x Impostor.Server
    rm Impostor-Server_1.2.2-ci.124_linux-x64.tar.gz
    fi
    if [ "$arch" == 'armv*' ];
    then
    wget https://ci.appveyor.com/api/buildjobs/1g7x9s6vkvr5wbqm/artifacts/build%2FImpostor-Server_1.2.2-ci.124_linux-arm64.tar.gz
    tar -zxvf Impostor-Server_1.2.2-ci.124_linux-arm64.tar.gz
    sudo chmod +x Impostor.Server
    rm Impostor-Server_1.2.2-ci.124_linux-arm64.tar.gz
    fi
    sudo cat > /etc/systemd/system/impostor.service <<EOF
[Unit]
Description=Among Us Impostor Server

Wants=network.target
After=syslog.target network-online.target

[Service]
Type=simple
ExecStart=/usr/local/impostor/Impostor.Server
Restart=on-failure
RestartSec=10
KillMode=process

[Install]
WantedBy=multi-user.target
EOF
    sudo chmod 640 /etc/systemd/system/impostor.service
    sudo systemctl enable impostor
    sudo systemctl start impostor
}

BuildFromSource() {
    sudo apt-get update
    sudo apt-get install -y git apt-transport-https
    wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    sudo apt-get update
    sudo apt-get install -y dotnet-sdk-5.0
    git clone --recursive https://github.com/AeonLucid/Impostor.git /tmp/impostor-source
    git submodule update --init
    cd /tmp/impostor-source/src/Impostor.Server/
    dotnet build -o /usr/local/impostor
    sudo cat > /etc/systemd/system/impostor.service <<EOF
[Unit]
Description=Among Us Impostor Server

Wants=network.target
After=syslog.target network-online.target

[Service]
Type=simple
ExecStart=/usr/local/impostor/Impostor.Server
Restart=on-failure
RestartSec=10
KillMode=process

[Install]
WantedBy=multi-user.target
EOF
    sudo chmod 640 /etc/systemd/system/impostor.service
    sudo systemctl enable impostor
    sudo systemctl start impostor
}

# System messages
__line="-----------------------------------------------"
__welcomeascii="
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣤⣤⣤⣤⣤⣶⣦⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⡿⠛⠉⠙⠛⠛⠛⠛⠻⢿⣿⣷⣤⡀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⠋⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⠈⢻⣿⣿⡄⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣸⣿⡏⠀⠀⠀⣠⣶⣾⣿⣿⣿⠿⠿⠿⢿⣿⣿⣿⣄⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣿⣿⠁⠀⠀⢰⣿⣿⣯⠁⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣷⡄⠀
⠀⠀⣀⣤⣴⣶⣶⣿⡟⠀⠀⠀⢸⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣷⠀
⠀⢰⣿⡟⠋⠉⣹⣿⡇⠀⠀⠀⠘⣿⣿⣿⣿⣷⣦⣤⣤⣤⣶⣶⣶⣶⣿⣿⣿⠀
⠀⢸⣿⡇⠀⠀⣿⣿⡇⠀⠀⠀⠀⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠃⠀
⠀⣸⣿⡇⠀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠉⠻⠿⣿⣿⣿⣿⡿⠿⠿⠛⢻⣿⡇⠀⠀
⠀⣿⣿⠁⠀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣧⠀⠀
⠀⣿⣿⠀⠀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⠀⠀
⠀⣿⣿⠀⠀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⠀⠀
⠀⢿⣿⡆⠀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⡇⠀⠀
⠀⠸⣿⣧⡀⠀⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠃⠀⠀
⠀⠀⠛⢿⣿⣿⣿⣿⣇⠀⠀⠀⠀⠀⣰⣿⣿⣷⣶⣶⣶⣶⠶⠀⢠⣿⣿⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀⣿⣿⡇⠀⣽⣿⡏⠁⠀⠀⢸⣿⡇⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀⣿⣿⡇⠀⢹⣿⡆⠀⠀⠀⣸⣿⠇⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢿⣿⣦⣄⣀⣠⣴⣿⣿⠁⠀⠈⠻⣿⣿⣿⣿⡿⠏⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⠛⠻⠿⠿⠿⠿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
__welcometext1="Welcome! This script is created to automate the installation process of the Impostor game server."
__welcometext2="Impostor is one of the first Among Us private servers, written in C#."
__welcometext3="The Impostor project is a reverse engineered and open sourced server for Among Us."
__welcometext4="The game itself is developed by InnerSloth while this project is maintained by the community."
__welcometext5="This script is created by Wolf20482#3390 and Dimaguy#7491"
__confirmationPrompt="Do you want to install Impostor? [y/n]"
__installationTypePrompt="What method do you want to use to install Impostor?
1. Download precompiled source code and run
2. Build from source
Please enter your choice. [1/2]"
echo "$__line"
tput setaf 1; echo "$__welcomeascii"
echo "$__welcometext1"
echo "$__welcometext2"
echo "$__welcometext3"
echo "$__welcometext4"
echo "$__welcometext5"

while [ "$go" != 'y' ] && [ "$go" != 'n' ]
do
    read -p "$__confirmationPrompt" go;
done

if [ "$go" == 'n' ];then
    exit;
fi

while [ "$build" != 'y' ] && [ "$build" != 'n' ]
do
    read -p "$__installationTypePrompt" build;
done

if [ $server_ram_total -lt $low_ram ]; then
	echo -e "Your RAM is too low for running Impostor properly. \n (at least 256MB) \n"
	echo "Cancelling installation..."
	exit
fi
sleep 3

clear
if [ "$build" == 'n' ];then
    PrecompiledInstallation;
else
    BuildFromSource;
fi
