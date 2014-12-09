#!/bin/bash
#author:finy
#mail jos666@qq.com

#set passwd
read -p "Input passwod:" passwd

if [  -z "$passwd" ];then
	passwd="testpasswd"
fi



scriptname=/root/shdownsocks.sh

#see diff
check_diff(){
	r=$(diff $1 $2|wc -l)
	if [ "$r" != 1 ];then
		echo 0
	else
		echo 1
	fi
}


#create master script
create_script(){
	if [ -f $scriptname ];then
		tempfile=/tmp/a.sh
		write_script $tempfile
		if [ "$(check_diff $scriptname $tempfile)" == "0" ];then
			rm -f $scriptname
			mv $tempfile $scriptname
		fi
	else
		write_script $filename
	fi
}


#write script to disk
write_script(){
	filename=$1
	cat >>$filename<<EOF
port=9999
ip=\$(ifconfig eth0 | awk '{if(\$1=="inet")print \$2}'| awk -F":" '{print \$2}')
pass="$passwd"

check(){
	key=\$1
	result=\$(netstat -ntlp|grep \$key )
	echo "Check: \$result" >/dev/null 2>&1
	if [ "\$result" == "" ];then
		ssserver -s \$ip -p \$port -k \$pass --workers 10 1>/dev/null 2>&1&
	fi
}



init(){
	proc="/usr/bin/ssserver"
	package="shadowsocks"
	if [ ! -f "\$proc" ];then
		if [ ! -f "/usr/bin/easy_install" ];then yum install python-setuptools -y 1>/dev/null 2>&1;fi
		easy_install pip 1>/dev/null 2>&1
		pip install \$package 1>/dev/null 2>&2
		result=\$(python -c "import shadowsocks" 2>&1 | wc -l)
		if [ "\$result" == "1" ];then pip install \$package;fi
	fi	
		
}
init
check \$port
EOF
	chmod 755 $filename
}

#auto monitor python process
add_cron(){
	if [ -z "$(grep $scriptname /etc/crontab)"];then
		echo "10/* * * * *  root $scriptname" >> /etc/crontab
	fi
}

#main
create_script
add_cron
