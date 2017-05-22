FROM kalilinux/kali-linux-docker

ADD root/ /

ENV DEBIAN_FRONTEND noninteractive

COPY sources.list /etc/apt/sources.list

# Install packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server pwgen supervisor && \
    mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
    sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && \
    sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

# Install metasploit
RUN apt-get -y --force-yes install ruby metasploit-framework

VOLUME ["/root","/app"]

EXPOSE 22 80 6379 443 21 23 8080 8888 8000 27017 3306 9200 9300

RUN chmod 777 /*.sh
CMD ["/run.sh"]