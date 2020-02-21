#!/bin/bash
set +x

source config.src

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

OLD_PUBLIC_IP="none"

while [ 1 ] ; do
  #PUBLIC_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
  #PUBLIC_IP=$(curl ifconfig.me)
  PUBLIC_IP=$(${PUBLIC_IP_COMMAND})


  echo PUBLIC_IP=${PUBLIC_IP}

  if valid_ip ${PUBLIC_IP} ; then
  
    if [ "${PUBLIC_IP}x" != "${OLD_PUBLIC_IP}x" ] ; then
      set -x
      curl -X POST "https://${USERNAME}:${PASSWORD}@domains.google.com/nic/update?hostname=${HOSTNAME}&myip=${PUBLIC_IP}"
      set +x
      OLD_PUBLIC_IP=${PUBLIC_IP}
      echo ""
    fi
  else
    echo "ip not valid"
  fi

  sleep 5m
done