echo -e "\nResult:"; check=`cat /etc/fstab | grep -w /var`; if [[ -z $check ]]; then echo "Khong tim thay phan vung /var trong /etc/fstab ==> WARNING";else echo "Phan vung /var tach rieng voi phan vung / ==> OK"; fi; echo "";
echo -e "\nResult:"; check=`cat /etc/fstab | grep -vw "#\|/\|/var\|/dev/shm\|/home\|/usr\|/proc\|/sys\|/dev/pts\|/opt\|swap\|/boot\|/boot/efi"`; if [[ -z $check ]]; then echo "Khong tim thay phan vung ung dung (/u01...) trong /etc/fstab ==> WARNING";else echo "Phan vung ung dung (/u01...) tach rieng voi phan vung / ==> OK"; fi; echo "";
echo -e "\nResult:"; check=`date +"%Z %z" | grep -w 0700`; if [[ $check == *0700* ]]; then echo "Timezone +7 ==> OK";else echo "$check ==> WARNING"; fi; echo "";
echo -e "\nResult:"; standard=`echo -e "%wheel\tALL=(ALL)\tALL"`; check=`cat /etc/sudoers | grep -v ^# | grep "$standard"`; if [[ -z $check ]]; then echo "Khong ton tai: $standard ==> OK"; else echo -e "Ton tai: $check  ==> WARNING";fi; echo "";
echo -e "\nResult:"; standard=`echo -e "ALL=(ALL)\tALL"`; list=`cat /etc/passwd |grep /bin/bash  | grep -v ^# | grep -v nfsnobody | awk -F: '($3>=400) {print $1}'`; for i in $list; do check=`cat /etc/sudoers | grep -v ^# | grep -w "$i" | grep "$standard"`; if [[ -z $check ]]; then echo -e "Khong ton tai: $i\t$standard ==> OK"; else echo -e "Ton tai: $check  ==> WARNING";fi; done; echo "";
echo -e "\nResult:"; check=`ps -ef | grep ^root | grep "java\|tomcat\|jre\|jdk" | grep -v grep`; if [[ -z $check ]]; then echo "Khong co tien trinh dich vu (java|tomcat|jre|jdk) chay bang root ==> OK";else echo -e "Co tien trinh dich vu (java|tomcat|jre|jdk) chay bang root\n $check \n==> WARNING"; fi; echo "";

echo -e "\nResult:"; vmware=`dmidecode -t system | grep -w "VMware"`; bond=`ip a | grep -v "bond[0-9]:"| grep -A 2 UP | grep -A 2 BROADCAST | grep -v "inet6\|172.16" | grep -v "docker0" | grep inet`; openstack=`dmidecode -t system | grep -w "OpenStack"`; list=`ip a | grep "bond[0-9]:" | awk '{print $2}' | awk -F: '{print $1}' | grep "bond[0-9]"`; if [[ $vmware == *VMware* ]] || [[ $openstack == *OpenStack* ]] ; then echo "Server VMware cung nhu OpenStack khong can bonding ==> OK"; elif [[ -z $bond ]]; then echo "Chi co card bonding co trang thai UP ==> OK"; else echo -e "Ton tai card mang trang thai UP khong phai la bonding card:\n$bond\n==> WARNING"; fi; echo "";


echo -e "\nResult:"; vmware=`dmidecode -t system | grep -w "VMware"`; list=`ip a | grep "bond[0-9]:" | awk '{print $2}' | awk -F: '{print $1}' | grep "bond[0-9]"`; openstack=`dmidecode -t system | grep -w "OpenStack"`; if [[ $vmware == *VMware* ]] || [[ $openstack == *OpenStack* ]] ; then echo "Server VMware cung nhu OpenStack khong can bonding ==> OK"; elif [[ -z $list ]]; then echo "Khong co bonding ==> WARNING"; else for i in $list; do check1=`cat /proc/net/bonding/"$i" | grep "Slave Interface" | wc -l`; if [ $check1 -lt 2 ]; then echo "Bonding co it hon 2 Interface active ==> WARNING"; break; else check2=`cat /proc/net/bonding/"$i" | grep "Slave Interface" | awk '{print $3}'`;  echo -e "\nBonding: $i"; for j in $check2; do port=`cat /proc/net/bonding/"$i" | grep -A 2 "Slave Interface: $j"| grep "MII Status" | awk '{print $3}'`; if [[ $port == "up" ]]; then echo -e "Slave Interface: $j\nMII Status: $port ==> OK"; else echo  "Slave Interface: $j\nMII Status: $port ==> WARNING"; fi; done; fi;done;fi; echo "";

echo -e "\nResult:"; vmware=`dmidecode -t system | grep -w "VMware"`; list=`ip a | grep "bond[0-9]:" | awk '{print $2}' | awk -F: '{print $1}' | grep "bond[0-9]"`; openstack=`dmidecode -t system | grep -w "OpenStack"`; list=`ip a | grep "bond[0-9]:" | awk '{print $2}' | awk -F: '{print $1}' | grep "bond[0-9]"`; if [[ $vmware == *VMware* ]] || [[ $openstack == *OpenStack* ]] ; then echo "Server VMware cung nhu OpenStack khong can bonding ==> OK"; elif [[ -z $list ]]; then echo "Khong co bonding ==> WARNING"; else for i in $list; do check1=`cat /etc/sysconfig/network-scripts/ifcfg-bond0 | grep -v ^# | grep "BONDING_OPTS"| sed 's/mode=/%/g'| cut -d '%' -f2| cut -d ' ' -f1`; check2=`cat /proc/net/bonding/$i | grep "Bonding Mode"`; if [[ $check1 == "1" && $check2 == *active-backup* ]]; then echo -e "$check1\t$check2\t==> OK"; elif [[ $check1 == "0" && $check2 == *round-robin* ]]; then echo -e "$check1\t$check2\t==> OK"; elif [[ $check1 == "4" && $check2 == *"IEEE 802.3ad"* ]]; then echo -e "$check1\t$check2\t==> OK"; elif [[ $check1 == "2" && $check2 == *xor* ]]; then echo -e "$check1\t$check2\t==> OK"; elif [[ $check1 == "5" && $check2 == *"transmit load balancing"* ]]; then echo -e "$check1\t$check2\t==> OK"; else echo -e "Bonding mode khong chinh xac:\n$check1\t$check2\t==> WARNING"; fi; done; fi; echo "";

echo -e "\nResult:"; list=`dmsetup status| grep -vw linear |awk '{print $1}'| sed -e 's/://g'| grep -v p[0-9]$| grep -v No`; if [[ -z $list ]]; then echo "Server khong co multipath ==> OK"; else for line in $list; do path=`multipath -ll $line | grep running$| wc -l`; if [[ $path -lt 4 ]] ; then echo "Server co line $line co $path path running < 4 ==> WARNING"; else echo "Server co line $line co $path path running >= 4 ==> OK"; fi; done; fi; echo "";
echo -e "\nResult:"; check=`systemctl status kdump | grep "Active: active"`; if [[ -z $check ]]; then echo "Kdump service not active ==> WARNING"; else echo -e "Kdump service is actived:\n$check\n==> OK";fi; echo "";
echo -e "\nResult:"; check=`systemctl status sendmail | grep "Active: active"`; if [[ -z $check ]]; then echo "sendmail service not active ==> OK"; else echo -e "sendmail service is actived:\n$check\n==> WARNING";fi; echo "";
echo -e "\nResult:"; check=`systemctl status postfix | grep "Active: active"`; if [[ -z $check ]]; then echo "postfix service not active ==> OK"; else echo -e "postfix service is actived:\n$check\n==> WARNING";fi; echo "";
echo -e "\nResult:"; check=`systemctl status NetworkManager | grep "Active: active"`; if [[ -z $check ]]; then echo "NetworkManager service not active ==> OK"; else echo -e "NetworkManager service is actived:\n$check\n==> WARNING";fi; echo "";
echo -e "\nResult:"; check=`ifconfig -a | grep virbr`; if [[ -z $check ]]; then echo "Khong ton tai card mang ao ==> OK"; else echo -e "Ton tai card mang ao:\n$check\n==> WARNING";fi; echo "";
echo -e "\nResult:"; check=`cat /etc/selinux/config | grep -v ^# | grep "SELINUX="`; check2=`sestatus | grep "Current mode" | grep "enforcing"`; if [[ $check == *SELINUX=disabled* && -z $check2 ]]; then echo -e "Selinux da disabled:\n$check\n$check2\n==> OK"; else echo -e "Selinux chua disabled:\n$check\n$check2\n==> WARNING";fi; echo "";
echo -e "\nResult:";standard="/proc/sys/net/nf_conntrack_max"; check=`cat $standard`; if [[ -z $check ]]; then echo "Chua cau hinh tham so $standard ==> WARNING"; elif [ $check -lt 524288 ]; then echo "$standard = $check < 524288 ==> WARNING"; else echo "$standard = $check >= 524288 ==> OK";fi; echo "";
echo -e "\nResult:";standard="/sys/module/nf_conntrack_ipv4/parameters/hashsize"; check=`cat $standard`; if [[ -z $check ]]; then echo "Chua cau hinh tham so $standard ==> WARNING"; elif [ $check -lt 131072 ]; then echo "$standard = $check < 131072 ==> WARNING"; else echo "$standard = $check >= 131072 ==> OK";fi; echo "";
echo -e "\nResult:"; list=`cat /etc/passwd |grep /bin/bash  | grep -v ^# | grep -v nfsnobody | awk -F: '($3>=400) {print $1}'`; for user in $list;do check=`chage -l $user | grep "Password expires" |  awk '{print $4}'`; if [[ $check = "never" ]]; then echo "$user: Password expires: $check ==> OK"; else echo "$user: Password expires: $check ==> WARNING"; fi;done; echo "";
echo -e "\nResult;"; list=`cat /etc/passwd |grep "/bin/bash" | grep -v ^# | grep -v nfsnobody | awk -F: '($3>=400) {print $1}'`; for user in $list;do check=`cat /etc/security/limits.conf | grep -v ^# | grep -w $user | grep -v soft | grep -w nofile`; if [[ -n $check ]]; then echo "$check ==> OK"; else echo "$user: chua cau hinh nofile ==> WARNING"; fi;done; echo "";
echo -e "\nResult:"; list=`cat /etc/passwd |grep /bin/bash  | grep -v ^# | grep -v nfsnobody | awk -F: '($3>=400) {print $1}'`; for user in $list;do check=`cat /etc/security/limits.conf | grep -v ^# | grep -w $user | grep -v soft | grep -w nproc`; if [[ -n $check ]]; then echo "$check ==> OK"; else echo "$user: chua cau hinh nproc ==> WARNING"; fi;done; echo "";
echo -e "\nResult:"; check=`cat /proc/sys/fs/file-max`; check2=`cat /etc/sysctl.conf | grep -v ^# | grep -w  fs.file-max`; if [[ ! -z $check && ! -z $check2 ]]; then echo -e "Da cau hinh max open file server:\n/proc/sys/fs/file-max = $check\n$check2\n==> OK"; else echo -e "Chua cau hinh max open file server:\n/proc/sys/fs/file-max = $check\n$check2\n==> WARNING"; fi; echo "";
echo -e "\nResult:"; check=`systemctl status bluetooth | grep "Active: active"`; if [[ -z $check ]]; then echo "bluetooth service not active ==> OK"; else echo -e "bluetooth service is actived:\n$check\n==> WARNING";fi; echo "";
echo -e "\nResult:"; check=`systemctl status cups | grep "Active: active"`; if [[ -z $check ]]; then echo "cups service not active ==> OK"; else echo -e "cups service is actived:\n$check\n==> WARNING";fi; echo "";
echo -e "\nResult:"; check=`cat /etc/pam.d/su | grep -v ^# | grep -w auth | grep -w required | grep -w pam_wheel.so`; if [[ -z $check ]]; then echo "Chua cau hinh chi cho phep user thuoc group wheel duoc su root ==> WARNING"; else echo -e "Da cau hinh chi cho phep user thuoc group wheel duoc su root:\n$check\n==> OK";fi; echo "";
echo -e "\nResult:"; check=`cat /etc/pam.d/system-auth | grep -v ^# | grep -w password | grep -w "retry=3" | grep -w "minlen=8" | grep -w "dcredit=-1" | grep -w "ucredit=-1" | grep -w "ocredit=-1" | grep -w "lcredit=-1"`; if [[ -z $check ]]; then echo "Chua cau hinh password kho (retry 3 minlen 8 hoa thuong so ky tu?) ==> WARNING"; else echo -e "Da cau hinh chi password kho:\n$check\n==> OK";fi; echo "";
echo -e "\nResult:"; check=`cat /etc/pam.d/system-auth | grep -v ^# | grep -w password | grep -w sha512 | grep -w "remember=5"`; if [[ -z $check ]]; then echo "Chua cau hinh password kho (sha512 remember 5?) ==> WARNING"; else echo -e "Da cau hinh chi password kho:\n$check\n==> OK";fi; echo "";
echo -e "\nResult:"; check=`authconfig --test | grep hashing | grep sha512`; if [[ -z $check ]]; then echo "Chua cau hinh ma hoa sha512 ==> WARNING"; else echo -e "Da cau hinh ma hoa sha512:\n$check\n==> OK";fi; echo "";
echo -e "\nResult:"; check=`cat /etc/ssh/sshd_config | grep -v ^# | grep -w "Protocol 2"`; if [[ -z $check ]]; then echo "Chua cau hinh Protocol 2 ==> WARNING"; else echo -e "Da cau hinh Protocol 2:\n$check\n==> OK";fi; echo "";
echo -e "\nResult:"; check=`cat /etc/ssh/sshd_config | grep -v ^# | grep -w "PermitRootLogin no"`; if [[ -z $check ]]; then echo "Chua cau hinh PermitRootLogin no ==> WARNING"; else echo -e "Da cau hinh PermitRootLogin no:\n$check\n==> OK";fi; echo "";
echo -e "\nResult:\nCac user co uid >=400 va co quyen bash:"; list=`cat /etc/passwd |grep /bin/bash  | grep -v ^# | grep -v nfsnobody | awk -F: '($3>=400) {print $1}'`; for user in $list;do check=`cat /etc/ssh/sshd_config | grep -v ^# | grep -w AllowUsers | grep -w $user`; if [[ $check == *$user* ]] ; then echo "$user OK"; else echo "$user WARNING"; fi; done; echo "";
echo -e "\nResult:"; check=`cat /etc/profile | grep -v ^# | grep -w "TMOUT=300" -A 2 | grep -w "readonly TMOUT" -A 1 | grep -w "export TMOUT"`; if [[ -z $check ]]; then echo "Chua cau hinh TMOUT theo quy dinh ==> WARNING"; else echo -e "Da cau hinh TMOUT theo quy dinh ==> OK";fi; echo "";
echo -e "\nResult:"; list=`ip a | grep "state UP" | awk '{print $2}'| awk -F: '{print $1}'`; for i in $list; do check=`ethtool "$i" | grep "Speed" | awk '{print $2}'| awk -FM '{print $1}'`; if [ $check -lt 1000 ]; then echo "Card mang $i co Speed: $check Mb/s ==> WARNING"; else echo "Card mang $i co Speed: $check Mb/s ==> OK"; fi; done; echo "";
echo -e "\nResult:"; array=("1.0.1e" "1.0.2k" "1.0.1u" "1.0.2j" "1.1.0a" "1.1.0g" "1.0.2n"); variable="WARNING"; for i in "${array[@]}"; do check=`openssl version -a | grep "$i"`; if [[ ! -z $check ]]; then echo "$check ==> OK"; variable="OK"; break; fi; done; if [[ $variable == WARNING ]]; then echo "Version OpenSSL khong nam trong whitelist ==> $variable";fi; echo "";
echo -e "\nResult:"; check1=`find / -xdev \( -nouser -o -nogroup \) -print`;check2=`ps -ef | grep docker`;if [[ -z $check1 || ! -z $check2 ]]; then echo "Khong co file unowner ==> OK"; else echo "Ton tai file unowner ==> WARNING";fi; echo "";

echo -e "\nResult:"; check=`echo $PATH | grep "\./\|::\|/tmp"`; if [[ -z $check ]]; then echo "Khong co bien \$PATH nguy hiem ==> OK"; else echo -e "Ton tai bien \$PATH nguy hiem (./  ::  /tmp):\n$PATH ==> WARNING";fi; echo "";
echo -e "\nResult:"; check=`ls /etc/ | grep cron.deny`; if [[ -z $check ]]; then echo "Da xoa file /etc/cron.deny ==> OK"; else echo "Chua xoa file /etc/cron.deny ==> WARNING";fi; echo "";
echo -e "\nResult:"; check=`ls /etc/ | grep cron.allow`; if [[ -z $check ]]; then echo "Chua tao file /etc/cron.allow ==> WARNING"; else echo "Da tao file /etc/cron.allow ==> OK";fi; echo "";
#echo -e "\nResult:"; check1=`crontab -l | grep -v ^# | grep -v ntpdate`; check2=`crontab -l | grep -v ^# | grep ntpdate| grep "\-u"`; if [[ -z $check1 && $check2 == *ntpdate* ]]; then echo -e "Da gioi han crontab toi thieu:\n$check2 ==> OK"; elif [[  -z $check1 && -z $check2 ]]; then echo -e "Chua cau hinh crontab toi thieu (dong bo thoi gian) ==> WARNING"; else echo -e "Chua cau hinh crontab toi thieu:\n$check2\n$check1\n==> WARNING"; fi; echo "";
echo -e "\nResult:"; check1=`crontab -l | grep -v ^# | grep -v ntpdate | grep -v 'sh\b'`; check2=`crontab -l | grep -v ^# | grep ntpdate| grep "\-u"`; if [[ -z $check1 && $check2 == *ntpdate* ]]; then echo -e "Da gioi han crontab toi thieu:\n$check2 ==> OK"; elif [[  -z $check1 && -z $check2 ]]; then echo -e "Chua cau hinh crontab toi thieu (dong bo thoi gian) ==> WARNING"; else echo -e "Chua cau hinh crontab toi thieu:\n$check2\n$check1\n==> WARNING"; fi; echo "";
echo -e "\nResult:"; array=("/var/log/cron" "/var/log/maillog" "/var/log/messages" "/var/log/secure" "/var/log/spooler" "{" "compress" "sharedscripts" "postrotate" "/bin/kill -HUP \`cat /var/run/syslogd.pid 2> /dev/null\` 2> /dev/null || true"  "endscript" "}"); for i in "${array[@]}"; do check=`cat /etc/logrotate.d/syslog | grep -v ^# | grep -w "$i"`; if [[ $check == *$i* ]] ; then echo "$i ==> OK" ; else echo "$i ==> WARNING";fi;done; echo "";
echo -e "\nResult:"; array=("weekly" "rotate 12" "create" "dateext" "include /etc/logrotate.d" "/var/log/wtmp {" "create 0664 root utmp" "}" "/var/log/btmp {" "create 0600 root utmp" "}"); for i in "${array[@]}"; do check=`cat /etc/logrotate.conf | grep -v ^# | grep -w "$i"`; if [[ $check == *$i* ]] ; then echo "$i ==> OK" ; else echo "$i ==> WARNING";fi;done; echo "";
echo -e "\nResult:"; array=("/var/log/cmdlog.log" "{" "compress" "weekly" "rotate 12" "sharedscripts" "postrotate" "/bin/kill -HUP \`cat /var/run/syslogd.pid 2> /dev/null\` 2> /dev/null || true" "endscript" "}"); for i in "${array[@]}"; do check=`cat /etc/logrotate.d/cmdlog | grep -v ^# | grep -w "$i"`; if [[ $check == *$i* ]] ; then echo "$i ==> OK" ; else echo "$i ==> WARNING";fi;done; echo "";
echo -e "\nResult:"; array=("/var/log/iptables/iptables.log" "{" "daily" "rotate 30" "copytruncate" "compress" "notifempty" "missingok" "}"); for i in "${array[@]}"; do check=`cat /etc/logrotate.d/iptables | grep -v ^# | grep -w "$i"`; if [[ $check == *$i* ]] ; then echo "$i ==> OK" ; else echo "$i ==> WARNING";fi;done; echo "";
echo -e "\nResult:"; i="export PROMPT_COMMAND"; check=`cat /etc/bashrc | grep -v ^# | grep -w "$i"`; if [[ $check == *$i* ]] ; then echo "$check ==> OK" ; else echo "$check ==> WARNING";fi; echo "";
echo -e "\nResult:"; array=("/var/log/cmdlog.log" "/var/log/iptables/iptables.log"); for i in "${array[@]}"; do check=`cat /etc/rsyslog.conf | grep -v ^# | grep -w "$i"`; if [[ $check == *$i* ]] ; then echo "$i ==> OK" ; else echo "$i ==> WARNING";fi;done; echo "";
echo -e "\nResult:"; check=`systemctl status iptables| grep "Active: active"`; if [[ -z $check ]]; then echo "iptables khong hoat dong ==> WARNING"; else echo "iptables dang hoat dong ==> OK";fi; echo "";
echo -e "\nResult:"; check=`/opt/se/salt-call vsm.status | grep "2014\|2017"`; if [[ -z $check ]]; then echo "Chua cai dat SIRC hoac SIRC khong hoat dong ==> WARNING_SIRC"; else echo "SIRC dang hoat dong ==> OK";fi; echo "";
echo -e "\nResult:"; check=`cat /proc/sys/vm/zone_reclaim_mode`; if [[ $check != 0 ]]; then echo -e "Tham so zone_reclaim_mode khac 0:\n/proc/sys/vm/zone_reclaim_mode=$check ==> WARNING"; else echo "Tham so zone_reclaim_mode=0 ==> OK";fi; echo "";
echo -e "\nResult:"; check=`ps -ef | grep mysql | grep -v ^root`; if [[ -z $check ]]; then echo "mysql not active ==> OK"; else echo -e "mysql is actived:\n$check\n==> WARNING";fi; echo "";
echo -e "\nResult:"; check=`cat /proc/swaps | tail -n+2`; if [[ -z $check ]]; then echo "Server khong co Swap ==> WARNING"; else echo "Server da co Swap ==> OK";fi; echo "";
echo -e "\nResult:"; if [[ -e /etc/sysconfig/oracleasm ]]; then check1=`cat /etc/sysconfig/oracleasm | grep -v ^#| grep ORACLEASM_SCANORDER | grep -i dm |wc -l`; check2=`cat /etc/sysconfig/oracleasm | grep -v ^#| grep ORACLEASM_SCANEXCLUDE | grep -i sd |wc -l`; if [[ $check1 > 0 && $check2 > 0 ]]; then echo -e "\nORACLEASM_SCANORDER: $check1\nORACLEASM_SCANEXCLUDE: $check2\n==> OK"; else echo -e "\nORACLEASM_SCANORDER: $check1\nORACLEASM_SCANEXCLUDE: $check2\n==> WARNING"; fi; else echo "Server khong co file /etc/sysconfig/oracleasm ==> OK"; fi; echo "";
echo -e "\nResult:"; vmware=`dmidecode -t system | grep -i "Vmware\|OpenStack"`; if [[ -z $vmware ]]; then echo "Server vat ly khong can haveged ==> OK"; else check=`rpm -qa | grep haveged`; if [[ -z $check ]]; then echo "Server ao hoa khong cai dat haveged ==> WARNING"; else checkrunning=`service haveged status 2>/dev/null | grep running`; if [[ -z $checkrunning ]]; then echo "Service haveged not running ==> WARNING"; else echo "Service haveged is running ==> OK"; fi; fi; fi; echo "";
echo -e "\nResult:"; array=("telnet" "sysstat" "lsof" "dmidecode" "net-tools" "pciutils" "iptables-services" "ntp" "ftp" "nmap" "iotop" "wget" "zip" "unzip" "sysfsutils" "traceroute" "e2fsprogs"); for i in "${array[@]}"; do check=`rpm -qa | grep ^$i-`; if [[ ! -z $check ]] ; then echo "$i ==> OK" ; else echo "$i ==> WARNING";fi;done; echo "";
echo -e "\nResult:"; check=`cat /proc/sys/vm/swappiness`; if [[ -z $check || $check -gt 10 ]]; then echo "Server cau hinh Swappiness khong dung: Swappiness=$check ==> WARNING"; else echo "Server da cau hinh Swappiness=$check ==> OK";fi; echo "";