#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "Usage: sudo pi-puppet-bootstrap.sh" 1>&2
   exit 1
fi

# Make sure we have a sensible hostname
echo "Enter a hostname: "
read NEWHOSTNAME
hostname $NEWHOSTNAME
echo $NEWHOSTNAME > /etc/hostname

# Download and install puppet
mkdir setup-temp
cd setup-temp
wget https://apt.puppetlabs.com/puppetlabs-release-wheezy.deb || exit 1
dpkg -i puppetlabs-release-wheezy.deb || exit 1
apt-get update || exit 1
apt-get install puppet || exit 1

# Initial puppet run!
puppet agent -t || exit 1