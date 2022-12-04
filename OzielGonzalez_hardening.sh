#!/bin/bash

read -p "Ingrese la direccion o nombre de su archivo con las ips: " input_name
read -p 'Ingresa la ruta de tu key para la conexion por ssh: ' input_Key

while IFS= read line
do
    echo $line
    ssh $input_Key@$line

    #Aqui comienza a indagar el tipo de sistema operativo#
    lowercase(){
        echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
    }

    OS=`lowercase \`uname\``
    KERNEL=`uname -r`
    MACH=`uname -m`

    if [ "{$OS}" == "windowsnt" ]; then
        OS=windows
    elif [ "{$OS}" == "darwin" ]; then
        OS=mac
    else
        OS=`uname`
        if [ "${OS}" = "SunOS" ] ; then
            OS=Solaris
            ARCH=`uname -p`
            OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
        elif [ "${OS}" = "AIX" ] ; then
            OSSTR="${OS} `oslevel` (`oslevel -r`)"
        elif [ "${OS}" = "Linux" ] ; then
            if [ -f /etc/redhat-release ] ; then
                DistroBasedOn='RedHat'
                DIST=`cat /etc/redhat-release |sed s/\ release.*//`
                PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
                REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
            elif [ -f /etc/SuSE-release ] ; then
                DistroBasedOn='SuSe'
                PSUEDONAME=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
                REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
            elif [ -f /etc/mandrake-release ] ; then
                DistroBasedOn='Mandrake'
                PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
                REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
            elif [ -f /etc/debian_version ] ; then
                DistroBasedOn='Debian'
                DIST=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
                PSUEDONAME=`cat /etc/lsb-release | grep '^DISTRIB_CODENAME' | awk -F=  '{ print $2 }'`
                REV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
            fi
            if [ -f /etc/UnitedLinux-release ] ; then
                DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
            fi
            OS=`lowercase $OS`
        DistroBasedOn=`lowercase $DistroBasedOn`
            readonly OS
            readonly DIST
            readonly DistroBasedOn
            readonly PSUEDONAME
            readonly REV
            readonly KERNEL
            readonly MACH
        fi

    fi

    #Dependiendo del sistema operativo los comandos cambiaran#

    if [ $DistroBasedOn == debian ]; then
            echo "Tu sistema operativo es Ubuntu"
            sleep 2

            #Desinstalacion de antivirus
            sudo apt remove clamav -y
            sleep 2

            #actualizacion del sistema
            sudo apt-get update && sudo apt-get upgrade -y
            sleep 5

            #Instalacion de Antivirus
            sudo apt-get install clamav -y
            sleep 2

            sudo freshclam
            #sudo clamscan -r /home

    elif [ $DistroBasedOn == redhat ]; then
            echo "Tu sistema operativo es CentOS"
            sleep 2

            #Desinstalacion de antivirus
            sudo yum remove clamav -y
            sleep 2

            #actualizacion del sistema
            sudo yum update -y && sudo yum upgrade -y
            sleep 5

            #Instalacion de Antivirus
            sudo yum install clamav -y
            sleep 2

            sudo freshclam
            sleep 2

            #Instalacion de EPEL
            sudo yum install epel-release
    fi
    exit
done <$input_name