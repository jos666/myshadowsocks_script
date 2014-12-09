#!/bin/bash
#author:finy
#mail jos666@qq.com

#set passwd
read -p "Input passwod:" passwd
read -p "Input shdownsocks port:" port

[ -z "$passwd" ]&&passwd="testpasswd"
[ -z "$port" ]&&port=9999 



scriptname=/root/shdownsocks.sh
stopscript=/root/stopshdownsocks.sh

create_stop_script(){
	cat >>$stopscript<<EOF
kill -9 $(ps aux | grep ssserver| grep -v "grep"| awk '{print $2}')
EOF
}

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
	[ ! -f $stopscript ]&&create_stop_script
}


#write script to disk
write_script(){
	filename=$1
	cat >>$filename<<EOF
port=$port
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
	if [ -z "$(grep $scriptname /etc/crontab)" ];then
		echo "10/* * * * *  root $scriptname" >> /etc/crontab
	fi
}

view_info(){
	$scriptname
	clear
	echo " "
	echo " "
	echo " "
	echo " "
	echo " "
	echo "                                 Server:$(ifconfig eth0 | awk '{if($1=="inet")print $2}'| awk -F":" '{print $2}')"
	echo "                                 Port: $port"
	echo "                                 Password: $passwd"
}
#main
create_script
add_cron
view_info
