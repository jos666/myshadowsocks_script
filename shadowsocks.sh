port=9999
ip=$(ifconfig eth0 | awk '{if($1=="inet")print $2}'| awk -F":" '{print $2}')
pass="test"

check(){
	key=$1
	result=$(netstat -ntlp|grep $key )
	echo "Check: $result" >/dev/null 2>&1
	if [ "$result" == "" ];then
		ssserver -s $ip -p $port -k $pass --workers 10 1>/dev/null 2>&1&
	fi
}



init(){
	proc="/usr/bin/ssserver"
	package="shadowsocks"
	if [ ! -f "$proc" ];then
		if [ ! -f "/usr/bin/easy_install" ];then yum install python-setuptools -y 1>/dev/null 2>&1;fi
		easy_install pip 1>/dev/null 2>&1
		pip install $package 1>/dev/null 2>&2
		result=$(python -c "import shadowsocks" 2>&1 | wc -l)
		if [ "$result" == "1" ];then pip install $package;fi
	fi	
		
}
init
check $port
