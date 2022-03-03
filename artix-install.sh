#!/bin/bash

BLUE=$(tput setaf 4)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
WHITE=$(tput sgr0)

clear
echo "${GREEN}Welcome to my artix install script!${WHITE}"

system=$(cat /sys/firmware/efi/fw_platform_size)
if [ "$system" = 64 ]
then
system=EFI
else
system=BIOS
fi
choicexit(){
echo "
       exit without save
"
exit
}
printgraph(){
echo "
    ${GREEN}╔══════════════════════════════════════════════════════════════╗${WHITE}

         ${BLUE}your choice${WHITE}


            bios mode               - $system
            root partition          - $rootpart
            boot partition          - $bootpart
            swap partition          - $swappart
            locale                  - $locale
            timezone                - $timezone
            user                    - $username
            hostname                - $hostname
            kernel                  - $kernel
			init					- $init"
if [ "$system" = EFI ]
then
echo "            (EFI) bootloader name   - $efiboot"
else
echo "            (BIOS) disk for grub    - $biosdisk"
fi
echo "            network                 - $network
            desktop environment     - $desktop
            display manager         - $display
            additional packages     - $extrapackages

    ${GREEN}╚══════════════════════════════════════════════════════════════╝${WHITE}"
}
printanswer(){
echo "    ${GREEN}╔══════════════════════════════════════════════════════════════╗${WHITE}
$answer
    ${GREEN}╚══════════════════════════════════════════════════════════════╝${WHITE}"
}

printpart(){
echo "    ${GREEN}╔══════════════════════════════════════════════════════════════╗${WHITE}

         ${BLUE}Partitioning...${WHITE}


$(lsblk | awk '{print "            " $0}')

    ${GREEN}╚══════════════════════════════════════════════════════════════╝${WHITE}"
}

answersystem(){
clear
answer="
        script detected $system mode

            Do you want change to another?
            s) - skip
            yes) - EFI > BIOS or vica versa
            any) - exit without change

"
printgraph
printanswer
read -p "           Your choice: " systemans
    case $systemans in
    yes)
        if [ "$system" = EFI ]
        then
        system=BIOS
        else
        system=EFI
        fi
    ;;
    s)
    ;;
    *)
    choicexit
    ;;
    esac
}

answerpart(){
clear
answer="

            Do you want to change the partitions?
            s) - skip
            yes) - open cfdisk
            any) - exit without change

"
printpart
printanswer
read -p "         Your choice: " part
    case $part in
    yes)
    cfdisk
    ;;
    s)
    ;;
    *)
    choicexit
    ;;
    esac
}

answerrootpart(){
clear
answer="

		Which partition you want to root (/)? (sdx# (eg.: sda2))

"
printpart
printanswer
read -p "         Your choice: " rootpart
}

answerbootpart(){
clear
answer="

		Which partition you want to boot? (sdx# (eg.: sda2))

"
printpart
printanswer
read -p "         Your choice: " bootpart
}

answerswappart(){
clear
answer="

		Do you want a swap partition?
			yes or no
"
printpart
printanswer
read -p "         Your choice: " swappart
    case $swappart in
    yes)
	swap
    ;;
    no)
	break
    ;;
    *)
    choicexit
    ;;
    esac
}

swap(){
clear
answer="

		Which partition you want to swap? (eg.: sda3)
			
"
printpart
printanswer
read -p "         Your choice: " swappart

mkswap /dev/$swappart
swapon /dev/$swappart
}

answerlocale(){
clear
answer="
        Choose locale (example hu_HU for Hungarian)

            s) - skip
            d) - default (en_US)
            empty) - exit without save

"
printgraph
printanswer
read -p "         Your choice: " localeans
    if [ -z "$localeans" ]
    then
    choicexit
    fi
    case $localeans in
    s)
    ;;
    d)
    locale=en_US
    ;;
    *)
    locale=$localeans
    ;;
    esac
}

answertimezone(){
clear
answer='
        Choose timezone (example Europe/Budapest)

            s) - skip
            d) - default (Europe/London)
            empty) - exit without save

'
printgraph
printanswer
read -p "         Your choice: " timezoneans
    if [ -z "$timezoneans" ]
    then
    choicexit
    fi
    case $timezoneans in
    s)
    ;;
    d)
    timezone="Europe/London"
    ;;
    *)
    timezone=$timezoneans
    ;;
    esac
}

answeruser(){
clear
answer='
         username:

            s) - skip
            empty) - exit without save

'
printgraph
printanswer
read -p "         Your choice: " usernameans
    if [ -z "$usernameans" ]
    then
    choicexit
    fi
    case $usernameans in
    s)
    ;;
    *)
    username=$usernameans
    ;;
    esac
}

answerhost(){
clear
answer="
        hostname:

            s) - skip
            empty) - exit without save

"
printgraph
printanswer
read -p "         Your choice: " hostnameans
    if [ -z $hostnameans ]
    then
    choicexit
    fi
    case $hostnameans in
    s)
    ;;
    *)
    hostname=$hostnameans
    ;;
    esac
}

answerkernel(){
clear
answer='
        Choose kernel

            1) - linux
            2) - linux-zen
            3) - linux-lts
            any) - exit without save

'
printgraph
printanswer
read -p "         Your choice: " kernelans
    case $kernelans in
    1)
    kernel=linux
    ;;
    2)
    kernel=linux-zen
    ;;
    3)
    kernel=linux-lts
    ;;
    *)
    choicexit
    ;;
    esac
}

answerinit(){
clear
answer='
        Choose init system

            1) - dinit
            2) - runit
            3) - openrc
			4) - s6
			5) - suite66
            any) - exit without save

'
printgraph
printanswer
read -p "         Your choice: " initans
    case $initans in
    1)
    init=dinit
    ;;
    2)
    init=runit
    ;;
    3)
    init=openrc
    ;;
	4)
	init=s6
	;;
	5)
	init=suite66
	;;
    *)
    choicexit
    ;;
    esac
}

answersystemadd(){
    case $system in
    BIOS)
    clear
    answer='
        Choose disk for grub ( /dev/sd* )

            s) - skip
            empty) - exit without save

    '
    printgraph
    printanswer
    lsblk
    echo " "
    read -p "         Your choice: " biosdiskans
        if [ -z "$biosdiskans" ]
        then
        choicexit
        fi
        case $biosdiskans in
        s)
        ;;
        *)
        biosdisk=$biosdiskans
        ;;
        esac
    ;;
    EFI)
    clear
    answer='
        Choose bootloader

            s) - skip
            d) - default (grub)
            empty) - exit without save

    '
    printgraph
    printanswer
    read -p "         Your choice: " efibootans
    echo " "
        if [ -z "$efibootans" ]
        then
        choicexit
        fi
        case $efibootans in
        s)
        ;;
        d)
        efiboot=grub
        ;;
        *)
        efiboot=$efibootans
        ;;
        esac
    ;;
    esac
}

answerdesktop(){
clear
answer='
        Choose a desktop environment
			(type neccesarry packages for the WM/DE you want)
            s) - skip
            sk) if you already print, but want delete
            empty) - exit with no changes

'
printgraph
printanswer
read -p "         Your choice: " desktopans
    if [ -z "$desktopans" ]
    then
    choicexit
    fi
    case $desktopans in
    s)
    ;;
    sk)
    desktop=
    ;;
    *)
    desktop=$desktopans
    ;;
    esac
}

answerdisplay(){
clear
answer='
        Choose a display manager

            (sddm, lightdm, gdm or another)
            s) - skip
            sk) if you already print, but want delete
            empty) - exit with no changes

'
printgraph
printanswer
read -p "         Your choice: " displayans
    if [ -z "$displayans" ]
    then
    choicexit
    fi
    case $displayans in
    s)
    ;;
    sk)
    display=
    ;;
    *)
    display=$displayans
    ;;
    esac
}

answerextrapackages(){
clear
answer='
       Choose additional packages

            (nano, kate, falkon or another)
            s) - skip
            empty) - exit with no changes

'
printgraph
printanswer
read -p "         Your choice: " extrapackagesans
    if [ -z $extrapackagesans ]
    then
    choicexit
    fi
    case $extrapackagesans in
    s)
    ;;
    sk)
    extrapackages=
    ;;
    *)
    extrapackages="$extrapackagesans"
    ;;
    esac
}

answerready(){
clear
answer='
       Are you sure?

         yes) - Proceed to install
         any) - retry
         empty) - exit with no changes

'
printgraph
printanswer
read -p "         Your choice: " readyans
    if [ -z $readyans ]
    then
    choicexit
    fi
    if [ $readyans = yes ]
    then
    ready=1
    fi
}

answerpassroot(){
    clear
    correct=no
    answer="
       type root password
    "
    until [ $correct = yes ]
        do
        clear
        printanswer
        artix-chroot /mnt passwd
        read -p "Did you enter the pass correctly (yes/no)? : " correct
        done
}

answerpassuser(){
    clear
    correct=no
    answer="
       Type user password
    "
    artix-chroot /mnt useradd -m -g users -G wheel -s /bin/bash $username
    echo "%wheel ALL=(ALL) ALL" >> /mnt/etc/sudoers
    until [ $correct = yes ]
        do
        clear
        printanswer
        artix-chroot /mnt passwd $username
        read -p "Did you enter the pass correctly (yes/no)? : " correct
        done
}

answerarchrepo(){
clear
answer='
       Do you want to install the traditional arch repositories?

	   		y) - yes
			n) - no
            s) - skip
            empty) - exit with no changes

'
printgraph
printanswer
read -p "         Your choice: " archrepoans
    if [ -z $archrepoans ]
    then
    choicexit
    fi
    case $archrepoans in
    s)
    ;;
	y)
	archrepo=yes
	;;
	n)
	archrepo=no
	;;
    esac
}

answerparu(){
clear
answer='
	Do you want to install paru (AUR)?

	   		y) - yes
			n) - no
            s) - skip
            empty) - exit with no changes

'
printgraph
printanswer
read -p "         Your choice: " paruans
    if [ -z $paruans ]
    then
    choicexit
    fi
    case $paruans in
    s)
    ;;
	y)
	paru=yes
	;;
	n)
	paru=no
	;;    
	esac
}

answerblackarchrepo(){
clear
answer='
       Do you want to install the blackarch repository?

	   		y) - yes
			n) - no
            s) - skip
            empty) - exit with no changes

'
printgraph
printanswer
read -p "         Your choice: " blackarchans
    if [ -z $blackarchans ]
    then
    choicexit
    fi
    case $blackarchans in
    s)
    ;;
	y)
	blackarchrepo=yes
	;;
	n)
	blackarchrepo=no
	;;
    esac
}

answerending(){
    clear
    answer='
       Do you want reboot or...

         1)Enter livecd
         2)Enter artix-chroot (reboot after exit)
         any) - reboot
    '
    printanswer
    read -p "         Your choice: " endingans
    case $endingans in
        1)
        clear
        exit
        ;;
        2)
        clear
        artix-chroot /mnt
        umount -R /mnt
        reboot
        ;;
        *)
        clear
        umount -R /mnt
        reboot
        ;;
    esac
}


ready=0
while [ $ready = 0 ]
do
answersystem
answerpart
answerrootpart
answerbootpart
answerswappart
answerlocale
answertimezone
answeruser
answerhost
answerkernel
answerinit
answersystemadd
answernetwork
answerdesktop
answerdisplay
answerextrapackages
answerarchrepo
answerparu
answerblackarchrepo
answerready
done

if [ $ready = 1 ]
then

mkfs.ext4 /dev/$rootpart
mount /dev/$rootpart /mnt
fi

if [ $system = EFI ]
then
	mkfs.fat -F32 /dev/$bootpart
	mkdir -p /mnt/boot/efi
	mount /dev/$bootpart /mnt/boot/efi
else
	mkfs.ext4 /dev/$bootpart
	mkdir /mnt/boot
	mount /dev/$bootpart /mnt/boot
fi

basestrap /mnt base base-devel $init elogind-$init networkmanager networkmanager-$init $kernel $kernel-headers linux-firmware grub os-prober efibootmgr neovim

if [ -n "$desktop" ]
then
	basestrap /mnt $desktop
fi

if [ -n "$display" ]
then
	basestrap /mnt $display $display-$init
fi

if [ -n "$extrapackages" ]
then
	basestrap /mnt $extrapackages
fi

echo $hostname > /mnt/etc/hostname

echo "127.0.1.1 localhost.localdomain $hostname" >> /mnt/etc/hosts

echo LANG="$locale.UTF-8" > /mnt/etc/locale.conf
echo "LC_COLLATE="C"" >> /mnt/etc/locale.conf

echo $locale.UTF-8 UTF-8 >> /mnt/etc/locale.gen
artix-chroot /mnt locale-gen

fstabgen -U /mnt >> /mnt/etc/fstab

artix-chroot /mnt ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
artix-chroot /mnt hwclock --systohc

case $system in
BIOS)
	artix-chroot /mnt grub-install --recheck $biosdisk
	artix-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
;;
EFI)
	artix-chroot /mnt grub-install
	artix-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
;;
esac

if [[ $init == dinit ]]; then
	artix-chroot /mnt dinitctl enable NetworkManager
elif [[ $init == runit ]]; then
	artix-chroot /mnt ln -s /etc/runit/sv/NetworkManager /run/runit/service
elif [[ $init == openrc ]]; then
	artix-chroot /mnt rc-update add NetworkManager
elif [[ $init == s6 ]]; then
	artix-chroot /mnt s6-rc-bundle-update -c /etc/s6/rc/compiled add default NetworkManager
elif [[ $init == suite66 ]]; then
	artix-chroot /mnt 66-enable NetworkManager
fi

if [ -n $display ]; then	
	if [[ $init == dinit ]]; then
		artix-chroot /mnt dinitctl enable $display
	elif [[ $init == runit ]]; then
		artix-chroot /mnt ln -s /etc/runit/sv/$display /run/runit/service
	elif [[ $init == openrc ]]; then
		artix-chroot /mnt rc-update add $display
	elif [[ $init == s6 ]]; then
		artix-chroot /mnt s6-rc-bundle-update -c /etc/s6/rc/compiled add default $display
	elif [[ $init == suite66 ]]; then
		artix-chroot /mnt 66-enable $display
	fi
fi

answerpassroot
answerpassuser

if [[ $archrepo == yes ]]; then
	artix-chroot /mnt pacman -S artix-archlinux-support
	pacman -S wget
	wget https://raw.githubusercontent.com/dovahkiin0424/artix-install/main/pacman.conf -O /mnt/etc/pacman.conf
	artix-chroot /mnt pacman-key --populate archlinux
fi

if [[ $paru == yes ]]; then
	artix-chroot /mnt git clone https://aur.archlinux.org/paru.git
	artix-chroot /mnt cd paru
	artix-chroot /mnt makepkg -si
fi

if [[ $blackarchrepo == yes ]]; then
	curl -O https://blackarch.org/strap.sh
	chmod +x strap.sh
	artix-chroot /mnt ./strap.sh
fi

answerending

fi
