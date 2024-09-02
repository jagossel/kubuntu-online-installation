#!/bin/bash

apt-get update
apt-get install -y gpg wget

# Largely based off of Mozilla's page:
# https://support.mozilla.org/en-US/kb/install-firefox-linux#w_install-firefox-deb-package-for-debian-based-distributions-recommended
if [ ! -d '/etc/apt/keyrings' ]; then
	install -d -m 0755 /etc/apt/keyrings
fi

if [ ! -f '/etc/apt/keyrings/packages.mozilla.org.asc' ]; then
	wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
fi

if [ ! -f '/etc/apt/keyrings/packages.mozilla.org.asc' ]; then
	gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") print "\nThe key fingerprint matches ("$0").\n"; else print "\nVerification failed: the fingerprint ("$0") does not match the expected one.\n"}'
fi

if [ ! -f '/etc/apt/sources.list.d/mozilla.list' ]; then
	echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
fi

if [ ! -f '/etc/apt/preferences.d/mozilla' ]; then
	echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | tee /etc/apt/preferences.d/mozilla
fi

# Largely based off of Microsoft's page:
# https://code.visualstudio.com/docs/setup/linux
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg

if [ ! -f '/etc/apt/keyrings/packages.microsoft.gpg' ]; then
	install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
fi

if [ ! -f '/etc/apt/sources.list.d/vscode.list' ]; then
	echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null
fi

rm -f /tmp/packages.microsoft.gpg

# Largely based off of OBS Studio's page:
# https://obsproject.com/download
add-apt-repository -y ppa:obsproject/obs-studio

apt-get install -y apt-transport-https

apt-get update
apt-get install -y firefox code ffmpeg obs-studio dotnet-sdk-8.0 doomsday dosbox minetest blender gimp inkscape rtl-sdr fldigi qsstv audacious audacity kdenlive pavucontrol qsynth fluidsynth libreoffice virt-manager

# Download and install SDR++
wget -O /tmp/sdrpp_ubuntu_noble_amd64.deb https://github.com/AlexandreRouma/SDRPlusPlus/releases/download/nightly/sdrpp_ubuntu_noble_amd64.deb
if [ -f '/tmp/sdrpp_ubuntu_noble_amd64.deb' ]; then
	dpkg --install /tmp/sdrpp_ubuntu_noble_amd64.deb
	apt-get --fix-broken install -y
else
	echo === WARNING! ===
	echo SDR++ did not download, skipping installation.
	echo === WARNING! ===
fi

# Perform software update
apt-get upgrade

# Force restart via KDE Plasma
qdbus org.kde.Shutdown /Shutdown logoutAndReboot
