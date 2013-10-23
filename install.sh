#!/bin/bash

################################################################################
# A one-liner for installing New Relic Server Monitoring agent
# on CloudSigma's IaaS.
#
# Based on on https://github.com/vpetersson/bash_system_logic
################################################################################

# Make sure we're running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi


################################################################################
# Fetch system data (via Python)
################################################################################

## Returns 'Linux', 'Windows' etc.
OS=$(python -c 'import platform; print platform.system()')

## Returns 'Debian', 'Ubuntu', 'Fedora' etc.
DIST=$(python -c 'import platform; dist = platform.linux_distribution()[0]; print dist[0].upper() + dist[1:]')

## Returns the distribution version.
DISTVER=$(python -c 'import platform; print platform.linux_distribution()[1]')

## Returns '32bit' or '64bit'
ARCH=$(python -c 'import platform; print platform.architecture()[0]')

################################################################################
# Functions for various situations
################################################################################

## Generic Linux
function linux {

  # Get license key from meta data value 'new_relic_license'
  LICENSE=$(read -t 13 READVALUE < /dev/ttyS1 && echo $READVALUE & sleep 1; echo -en "<\n/meta/new_relic_license\n>" > /dev/ttyS1; wait %1)

  # Fall back if no key is present
  if [[ -z "$LICENSE" ]]; then
    echo "Unable to read New Relic key from meta data. Please enter it by hand:"
    read LICENSE
  fi
}

## Debian
function debian {
  # Based on https://docs.newrelic.com/docs/server/server-monitor-installation-ubuntu-and-debian
  echo "deb http://apt.newrelic.com/debian/ newrelic non-free" > /etc/apt/sources.list.d/newrelic.list
  wget --quiet -O- https://download.newrelic.com/548C16BF.gpg | apt-key add -
  apt-get -q update
  apt-get -y -q install newrelic-sysmond
  nrsysmond-config --set license_key=$LICENSE > /dev/null
  /etc/init.d/newrelic-sysmond start
}

## Ubuntu
function ubuntu {
  debian # Same as Debian
}

## CentOS
function centos {
  # Based on https://docs.newrelic.com/docs/server/server-monitor-installation-redhat-and-centos

  if [ $ARCH == '32bit' ]; then
    rpm -U --quiet https://yum.newrelic.com/pub/newrelic/el5/i386/newrelic-repo-5-3.noarch.rpm
  elif [ $ARCH == '64bit' ]; then
    rpm -U --quiet https://yum.newrelic.com/pub/newrelic/el5/x86_64/newrelic-repo-5-3.noarch.rpm
  fi

  yum install --quiet -y newrelic-sysmond
  nrsysmond-config --set license_key=$LICENSE > /dev/null
  /etc/init.d/newrelic-sysmond start
}

## RedHat Enterprise Linux
function redhat {
  centos # Use same as CentOS
}

################################################################################
# No need for making changes below here
################################################################################

if [ $OS == 'Linux' ]; then

  # Run on all Linux systems.
  linux

  # Debian
  if [ $DIST == 'Debian' ]; then
    debian
  # Ubuntu
  elif  [ $DIST = 'Ubuntu' ]; then
    ubuntu
  # CentOS
  elif [ $DIST = 'CentOS' ]; then
    centos
  # RedHat Enterprise Linux
  elif [ $DIST = 'RedHat' ]; then
    redhat
  else
    echo "$DIST is an unsupported Linux distribution"
    exit 1
  fi

else
  echo "$OS is an unsupported platform"
  exit 1
fi

