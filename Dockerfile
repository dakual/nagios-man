FROM ubuntu:18.04
MAINTAINER Daghan Kurtay Altunsoy <daghan.altunsoy@gmail.com>

ENV DEBIAN_FRONTEND         noninteractive
ENV NAGIOS_HOME             /opt/nagios
ENV NAGIOS_USER             nagios
ENV NAGIOS_GROUP            nagcmd
ENV NAGIOS_HTTP_USER        admin
ENV NAGIOS_HTTP_PASS        1234
ENV NAGIOS_VERSION          4.4.7
ENV NAGIOS_PLUGINS_VERSION  2.3.3

RUN apt update
RUN apt-get install autoconf gcc libc6 make wget unzip apache2 php libapache2-mod-php libgd-dev libssl-dev -y
RUN useradd --system -d ${NAGIOS_HOME} ${NAGIOS_USER}
RUN groupadd ${NAGIOS_GROUP}
RUN usermod -a -G ${NAGIOS_GROUP} ${NAGIOS_USER}
RUN usermod -a -G ${NAGIOS_GROUP} www-data

RUN cd /tmp && \
	wget --no-check-certificate https://assets.nagios.com/downloads/nagioscore/releases/nagios-${NAGIOS_VERSION}.tar.gz && \
	tar -zxvf nagios-${NAGIOS_VERSION}.tar.gz && \
	cd nagios-${NAGIOS_VERSION} && \
	./configure \
		--exec-prefix=${NAGIOS_HOME} \
		--with-nagios-user=${NAGIOS_USER}        \
        	--with-nagios-group=${NAGIOS_USER}      \
		--with-command-group=${NAGIOS_GROUP} \
		--with-httpd-conf=/etc/apache2/sites-enabled \
		--prefix=${NAGIOS_HOME} && \
	make all && \
	make install && \
	make install-init && \
	make install-daemoninit	&& \
	make install-config && \
	make install-commandmode && \
	make install-webconf && \
	rm -rvf /tmp/nagios-${NAGIOS_VERSION} /tmp/nagios-${NAGIOS_VERSION}.tar.gz
	
RUN a2enmod rewrite
RUN a2enmod cgi

RUN htpasswd -c -b -s ${NAGIOS_HOME}/etc/htpasswd.users ${NAGIOS_HTTP_USER} ${NAGIOS_HTTP_PASS}

RUN cd /tmp && \
	wget --no-check-certificate https://nagios-plugins.org/download/nagios-plugins-${NAGIOS_PLUGINS_VERSION}.tar.gz && \
	tar -zxvf nagios-plugins-${NAGIOS_PLUGINS_VERSION}.tar.gz && \
	cd nagios-plugins-${NAGIOS_PLUGINS_VERSION}  && \
	./configure \
		--with-nagios-user=${NAGIOS_USER} \
		--with-nagios-group=${NAGIOS_USER} \
		--prefix=${NAGIOS_HOME} && \
	make && \
	make install && \
	rm -rvf /tmp/nagios-${NAGIOS_PLUGINS_VERSION} /tmp/nagios-plugins-${NAGIOS_PLUGINS_VERSION}.tar.gz

RUN apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/*log /var/log/apt/* /var/lib/dpkg/*-old /var/cache/debconf/*-old
	
RUN ${NAGIOS_HOME}/bin/nagios -v ${NAGIOS_HOME}/etc/nagios.cfg

ADD start.sh ${NAGIOS_HOME}/
RUN chmod +x ${NAGIOS_HOME}/start.sh

EXPOSE 80
EXPOSE 5666

# Start Apache and Nagios
CMD ["/bin/bash", "/opt/nagios/start.sh"]

#CMD [ "main" ]
