#!/bin/bash

if [ "${AUTHORIZED_KEYS}" != "**None**" ]; then
    echo "=> Found authorized keys"
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
    touch /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    IFS=$'\n'
    arr=$(echo ${AUTHORIZED_KEYS} | tr "," "\n")
    for x in $arr
    do
        x=$(echo $x |sed -e 's/^ *//' -e 's/ *$//')
        cat /root/.ssh/authorized_keys | grep "$x" >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "=> Adding public key to /root/.ssh/authorized_keys: $x"
            echo "$x" >> /root/.ssh/authorized_keys
        fi
    done
fi

sed -i 's/.*StrictHostKeyChecking.*/    StrictHostKeyChecking no/' /etc/ssh/ssh_config

if [ ! -f /.root_pw_set ]; then
	/set_root_pw.sh
fi

# supervisor
sed -i 's/^files = .*/files = \/app\/supervisor_conf\/*.conf/' /etc/supervisor/supervisord.conf
mkdir -p /app/supervisor_conf

mkdir -p /app/mybash/

if [ "${MYENV}" == "**None**" ] || [ "${MYENV}" == "" ]; then
   #open apache2
   ln -s -f /supervisord-sshd.conf /app/supervisor_conf/supervisord-sshd.conf
else
    mkdir -p '/app/mybash/'${MYENV}
    if [ ! -f '/app/mybash/'${MYENV}'/run.sh' ] ; then
        cp /mybash_run.sh '/app/mybash/'${MYENV}'/run.sh'
    fi
    awk 'BEGIN { cmd="cp -ri /home/mybash/root /app/mybash/'${MYENV}'/"; print "n" |cmd; }'
fi

if [ -f /app/mybash/firstrun.sh ] ; then
    chmod 777 /app/mybash/firstrun.sh
    /app/mybash/firstrun.sh
fi

exec /usr/bin/supervisord -n
