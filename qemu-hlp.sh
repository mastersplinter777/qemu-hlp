#/bin/bash
#This is the qemu-helper script to help with creating virtual machines.
#Author: alexander.a.kuzmin@gmail.com

conf_folder="$HOME/.config/qemu"
conf_file="$HOME/.config/qemu/settings.cfg"
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NC="\033[0m"

#Works!
sys_info() {
	if [ -f "/usr/bin/qemu-system-$(uname -m)" ];
		then
		echo -e "****************************************************"
		echo -e "Qemu version: $(/usr/bin/qemu-system-$(uname -m) --version)"
		echo -e "On 	: $(uname -rom)"
		echo -e "CPU  $GREEN$(cat /proc/cpuinfo | grep 'model name' | sed 's/model name//g') ${NC}"
		echo -e "RAM (KB): $GREEN$(grep MemTotal /proc/meminfo | awk '{print $2}') ${NC}"
		echo -e "OS is installed in $([ -d /sys/firmware/efi ] && echo $GREEN UEFI ${NC} || echo BIOS) mode"
		echo -e "****************************************************"
	else 
		echo -e "$RED Qemu binary not found! Please build or install! ${NC}"
		exit_script
	fi
}

#Works!
basic_config() {
	mkdir $conf_folder
	touch $conf_file
	echo "vmpath=" > $conf_file
	set_path
	option_path
}

check_path() {
	vmpath_cfg=$(sed -n 's/vmpath=//p' $conf_file)
	if [ `$vmpath_cfg` = `$name` ] ; then
		echo "This path is already set!"
	else
		echo >> $(set_path) $vmpath_cfg
	fi
}

#Works!
vm_name() {
	echo -e "Enter your virtual machine name and press [ENTER]: "
	read namevm
	if [ -d "$qpath/$namevm" ]; 
		then
		echo -e "****************************************************"
		echo -e "Virtual machine $GREEN$namevm${NC} already exists! Please specify another name."
		echo -e "1: Create new virtual machine"
		echo -e "2: List virtual machines in $GREEN$qpath${NC}"
		echo -e "3: Return to the previous menu"
		echo -e "4: Configure existing virtual machine"
		echo -e "****************************************************"
    	read namevm_opt
			case $namevm_opt in
				[1]* ) vm_name;;
        		[2]* ) list_vm; vm_name;;
				[3]* ) option_path;;
				[4]* ) configure_vm;;
				* ) option_path
    		esac
	else
		echo -e "Creating virtual machine $namevm directory."
		echo -e "$GREEN"
		mkdir "$qpath/$namevm"
		echo -e "${NC}"
		configure_vm
		option_path
	fi
}

#Works!
vm_delete() {
	echo -e "Enter a virtual machine you want to delete and press [ENTER]: "
	list_vm
	read rmvm
	if [ -d "$qpath/$rmvm" ];
		then 
		echo -e "Do you really want to completely remove $RED$rmvm${NC}?"
		read rmvmyn
    		case $rmvmyn in
        			[YyYesYES] ) rm -rf "$qpath/$rmvm"; option_path;;
        			[NnNoNO] ) option_path;;
        		* ) option_path
    		esac
	fi
}

#Works!
configure_vm() {
	cd $qpath
	echo -e "$GREEN"
	ls -hl $qpath --color
	echo -e "${NC}"
	echo -e "Please choose a virtual machine to configure"
	read editcfg
	cd $editcfg
	if [ -f $editcfg.conf ];
		then
		echo -e "Configuration file found, modify it?"
		read modcfg
		case $modcfg in
					[YyYesYES] )
					inject_basic_cfg;; 
        			[NnNoNO] ) 
					option_path;;
        		* ) option_path
    	esac			
	else
		echo -e "Configuration file not found! Create it?"
		read crcfg
		case $crcfg in
					[YyYesYES] )
					touch "$editcfg.conf"; inject_basic_cfg;; 
        			[NnNoNO] ) 
					option_path;;
        		* ) option_path
    	esac
	fi	
}

#Works!
inject_basic_cfg() {
	echo -e "Use template for:"
	echo -e "1: Linux"
	echo -e "2: Windows"
	echo -e "3: OSX"
	echo -e "4: Create custom"
	echo -e "5: Previous menu"
	read inj_base_cfg
	case $inj_base_cfg in
			[1]* ) inj_linux;;
        	[2]* ) inj_windows;;
			[3]* ) inj_osx;;
			[4]* ) custom_vm;;
			[5]* ) vm_name;;
		* ) vm_name;;
    esac
}

#Works!
list_vm() {
	echo -e "****************************************************"
	echo -e "$GREEN"
	ls -hl $qpath --color
	echo -e "${NC}"
	echo -e "****************************************************"
}

#Works!
exit_script() {
	echo -e "$GREEN Exiting... ${NC}"
	exit
}

del_config() {
	if [ -d "$conf_folder" ];
		then
		echo -e "Do you really want to delete configuration in $RED$conf_folder${NC}?"
		read delcfg
		case $delcfg in
					[YyYesYES] )
					rm -rf "$conf_folder"; exit_script;; 
        			[NnNoNO] ) 
					check_config;;
        		* ) check_config
    	esac
	else
		echo -e "There is no configuration file! Nothing to delete!"
		check_config
	fi
}	
	
#Works!
option_path() {
	echo -e "****************************************************"
	echo -e "1: Create new virtual machine"
	echo -e "2: List virtual machines in $GREEN$qpath${NC}"
	echo -e "3: Return to the previous menu"
	echo -e "4: Exit"
	echo -e "5: Delete virtual machine"
	echo -e "6: Delete configuration"
	echo -e "7: Configure existing virtual machine"
	echo -e "****************************************************"
    		read optpath
			case $optpath in
        			[1]* ) vm_name;;
        			[2]* ) list_vm; option_path;;
					[3]* ) set_path;;
					[4]* ) exit_script;;
					[5]* ) vm_delete;;
					[6]* ) del_config;;
					[7]* ) configure_vm;;
        		* ) option_path
    		esac	
}

#Works!
set_path() {
	echo -e "Enter the path, where you want to store your virtual machines and press [ENTER]: "
	read qpath
	if [ -d "$qpath" ]; 
		then
		echo -e "Path $GREEN$qpath${NC} already exists! Do you want to choose another one? Y/N"
    		read setqpath
    		case $setqpath in
        			[YyYesYES] )
					set_path;;
        			[NnNoNO] ) 
					option_path;;
        		* ) set_path
    		esac
	else
		echo -e "Creating directory: $GREEN$qpath${NC}"
		mkdir "$qpath"
		echo -e "Writing $GREEN$qpath${NC} to configuration file"
		option_path
		#echo $qpath >> $(sed -n 's/vmpath=//p' $conf_file)
	fi
	
	#check_path
}

#Works!
check_config() {
	if [ -f $conf_file ]; then
		echo -e "Configuration file found, skipping creation..."
		set_path
	else
		echo -e "Configuration file not found, do you want to create it? Y/N"
    	read confyn
    		case $confyn in
        			[YyYesYES] ) basic_config;;
        			[NnNoNO] ) exit;;
        		* ) basic_config
    		esac
	fi
}


#first run
sys_info
check_config

