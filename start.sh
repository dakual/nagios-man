#!/bin/bash
/etc/init.d/nagios start
/etc/init.d/apache2 start
tail -f /var/log/apache2/access.log /var/log/apache2/error.log
