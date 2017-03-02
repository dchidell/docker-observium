FROM ubuntu:latest
MAINTAINER David Chidell

ENV OBSERVIUM_PW=87fGi74gsJT

COPY observium.sh /opt/observium.sh
COPY cron /etc/cron.d/observium
COPY hosts /opt/hosts

RUN \
 apt-get update && \
 apt-get install -y cron wget apache2 libapache2-mod-php7.0 php7.0-cli php7.0-mysql php7.0-mysqli php7.0-gd php7.0-mcrypt php7.0-json \
 php-pear snmp fping mariadb-server-10.0 mariadb-client-10.0 python-mysqldb rrdtool subversion whois mtr-tiny ipmitool \
 graphviz imagemagick && \
 apt-get install -y apache2 && \
 apt-get clean && \
 chmod a+x /opt/observium.sh && \
 service mysql start && \
 mysql -uroot -e "CREATE DATABASE observium DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;" && \
 mysql -uroot -e "GRANT ALL PRIVILEGES ON observium.* TO 'observium'@'localhost' IDENTIFIED BY '$OBSERVIUM_PW';" && \
 phpenmod mcrypt && \
 a2dismod mpm_event && \
 a2enmod mpm_prefork && \
 a2enmod php7.0 && \
 a2enmod rewrite

COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

EXPOSE 80/tcp 162/udp
WORKDIR /opt/
CMD ["/opt/observium.sh"]
