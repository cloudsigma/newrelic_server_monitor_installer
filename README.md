# NR Server Monitor agent installer

A one-liner to install the New Relic Server Monitor-agent on CloudSigma. The script will automatically read in the New Relic license key from the server [contextualization](http://www.cloudsigma.com/2013/09/06/introducing-server-contextualization/) (using the key 'new_relic_license').

## Status

The script currently works on:

 * CentOS
 * Debian
 * RedHat Enterprise Linux
 * Ubuntu

## Usage

You can either run the installer as a true one-liner:

    curl -sL https://raw.github.com/cloudsigma/newrelic_server_monitor_installer/master/install.sh | bash

Or, alternatively, you can save it to disk first, and then run:

    curl -o /tmp/nrsetup.sh https://raw.github.com/cloudsigma/newrelic_server_monitor_installer/master/install.sh
    chmod +x /tmp/nrsetup.sh && /tmp/nrsetup.sh && rm /tmp/nrsetup.sh
