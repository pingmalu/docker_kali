FROM kalilinux/kali-linux-docker

#时区设置
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ADD rootfile/ /
ADD root/ /root

ENV DEBIAN_FRONTEND noninteractive

COPY sources.list /etc/apt/sources.list

# Install packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server pwgen supervisor vim && \
    mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
    sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config && \
    sed -i "s/^#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
    # Install metasploit
    apt-get -y --force-yes install ruby metasploit-framework && \
    # 用完包管理器后安排打扫卫生可以显著的减少镜像大小.
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["/root","/app"]

EXPOSE 22 80 6379 443 21 23 8080 8888 8000 27017 3306 9200 9300

RUN chmod 777 /*.sh
CMD ["/run.sh"]