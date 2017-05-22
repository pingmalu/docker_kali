FROM pingmalu:kali

ADD run.sh /run.sh
ADD set_root_pw.sh /set_root_pw.sh
ADD supervisord-sshd.conf /supervisord-sshd.conf

COPY sources.list /etc/apt/sources.list
COPY kali.list /etc/apt/sources.list.d/kali.list
RUN apt-key adv --keyserver pgp.mit.edu --recv-keys ED444FF07D8D0BF6

# Install packages
RUN apt update && DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server pwgen supervisor && \
    mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
    sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && \
    sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

VOLUME ["/root","/app"]

EXPOSE 22 80 6379 443 21 23 8080 8888 8000 27017 3306 9200 9300

CMD ["/run.sh"]
