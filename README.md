### Nagios Monitoring Server
The default credentials for the web interface is nagiosadmin / nagios
```
docker run --name nagios  \
  -v /path-to-nagios/etc/:/opt/nagios/etc/ \
  -v /path-to-nagios/var:/opt/nagios/var/ \
  -v /path-to-nagios/ssmtp.conf:/etc/ssmtp/ssmtp.conf \
  -v /path-to-custom-plugins:/opt/Custom-Nagios-Plugins \
  -p 0.0.0.0:8080:80 \
  manios/nagios:latest
```

### Test configuration
```
docker exec -it mynagioscontainer bin/nagios -v etc/nagios.cfg
```

### Install Nagios Client on Ubuntu
NRPE packages are available under the default repositories on Ubuntu systems.
```
apt-get install nagios-nrpe-server
```

### Configure Nagios Client
In NRPE configuration, first we need to nrpe to which nagios servers it accepts requests, For example your Nagios server IP is 192.168.1.100, then add this IP to allowed hosts list. Edit NRPE configuration file /etc/nagios/nrpe.cfg and make the necessary changes like below:
> sudo nano /etc/nagios/nrpe.cfg 
```
 allowed_hosts=127.0.0.1, 192.168.1.100
```

### Update Command Definitions for NRPE
We must have define all the commands to be used by Nagios server. Some of them are pre-configured with the installation. 
> sudo nano /etc/nagios/nrpe.cfg 
```
command[check_users]=/usr/lib/nagios/plugins/check_users -w 5 -c 10
command[check_load]=/usr/lib/nagios/plugins/check_load -w 15,10,5 -c 30,25,20
command[check_hda1]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /dev/hda1
command[check_zombie_procs]=/usr/lib/nagios/plugins/check_procs -w 5 -c 10 -s Z
command[check_total_procs]=/usr/lib/nagios/plugins/check_procs -w 150 -c 200
```

Next, restart NRPE service. Now it is ready to listen to requests from Nagios server
```
sudo systemctl restart nagios-nrpe-server 
```

### Verify Connection from Nagios
```
check_nrpe -H 192.168.1.11 
NRPE v4.0.0
```

### Test from server
```
check_nrpe -H 127.0.0.1 -c check_load
```
