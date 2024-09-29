#!/bin/bash

if [ -z "$1" ]; then
	echo >&2 "The profile name is required."
	exit 1
fi

base_dir=$( dirname "$( readlink -f $0 )" )

package_list_path="$base_dir/packages.csv"
if [ ! -f $package_list_path ]; then
	echo >&2 "Cannot find the package list, $package_list_path."
	exit 1
fi

apt-get update

pre_install_scripts_path="$base_dir/pre-install-scripts.csv"
if [ -f "$pre_install_scripts_path" ]; then
	grep -E ".*,($1|\*)" $pre_install_scripts_path | while IFS= read -r record; do
		pre_install_script_filename=$( echo "$record" | awk -F, '{ print $1 }' )
		pre_install_script_path="$base_dir/pre-install-scripts/$pre_install_script_filename"
		if [ -f "$pre_install_script_path" ]; then
			bash $pre_install_script_path
		else
			echo "Skipping over $pre_install_script_path: file not found."
		fi
	done
else
	echo "Skipping over the pre-installation scripts; cannot find the path, $pre_install_scripts_path."
fi

apt-get update

package_list=$( grep -E ".*,($1|\*)" $package_list_path | awk -F, '{ print $1 }' | tr '\n' ' ' )
apt-get install -y $package_list

post_install_scripts_path="$base_dir/post-install-scripts.csv"
if [ -f "$post_install_scripts_path" ]; then
	grep -E ".*,($1|\*)" $post_install_scripts_path | while IFS= read -r record; do
		post_install_script_filename=$( echo "$record" | awk -F, '{ print $1 }' )
		post_install_script_path="$base_dir/post-install-scripts/$post_install_script_filename"
		if [ -f "$post_install_script_path" ]; then
			bash $post_install_script_path $1
		else
			echo "Skipping over $post_install_script_path: file not found."
		fi
	done
else
	echo "Skipping over the pre-installation scripts; cannot find the path, $post_install_scripts_path."
fi

# Perform software update
apt-get upgrade -y

# Force restart via KDE Plasma
qdbus org.kde.Shutdown /Shutdown logoutAndReboot
