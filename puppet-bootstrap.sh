#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "Usage: sudo puppet-bootstrap.sh" 1>&2
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
wget https://apt.puppetlabs.com/puppetlabs-release-`lsb_release -c -s`.deb || exit 1
dpkg -i puppetlabs-release-`lsb_release -c -s`.deb || exit 1
apt-get update || exit 1
apt-get install puppet || exit 1

# Find the server we're using
echo "Enter puppet master hostname: "
read PUPPETMASTER
puppet config set server $PUPPETMASTER --section main

# Set the environment
echo "Enter environment name: "
read PUPPETENV
puppet config set environment $PUPPETENV

# Initial puppet run!
puppet agent -t

echo "Sign and classify the node on the puppet master, then press enter"
read dummy

# Enable puppet
puppet agent --enable

# Enable pluginsync
puppet config set pluginsync true

# First real puppet run
puppet agent -t || exit 1
