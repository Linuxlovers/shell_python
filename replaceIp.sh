#! /bin/bash
#author:lixianzhuang

#define mycolor
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
ENDCH="\033[0m"
function myecho() {
        mycolour=$1
        myinfo=$2
        echo -e "$mycolour $myinfo $ENDCH"
}

# right ip 0
# wrong ip 1
function validate_ip()
{
        ip=$1
        if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
        then
                OIFS=$IFS
                IFS='.'
                ip=($ip)
                if [[ ${ip[0]} -gt 254 || ${ip[0]} -lt 0 || ${ip[1]} -gt 254 || ${ip[1]} -lt 0 || ${ip[2]} -gt 254 || ${ip[2]} -lt 0 || ${ip[3]} -gt 254 || ${ip[3]} -lt 0 || "${ip[0]}"x = ""x || "${ip[1]}"x = ""x || "${ip[2]}"x = ""x || "${ip[3]}"x = ""x ]]
                then
                        #echo "wrong ip"
                        echo 1
                else
                        #echo "right ip"
                        echo 0
                fi
        else
                echo 1
        fi
}

function replace_host_ip()
{
	local ip=$1
	sed -i "/incloudos/d" /etc/hosts
	echo "$ip incloudos" >> /etc/hosts
	if [[ ! -z `cat /etc/hosts | grep es` ]]
	then
		sed -i "/es/d" /etc/hosts
		echo "$ip es" >> /etc/hosts
	fi
	if [[ ! -z `cat /etc/hosts | grep iops` ]]
	then
		sed -i "/iops.inspur.com/d" /etc/hosts
		echo "$ip iops.inspur.com" >> /etc/hosts
		sed -i "/iops.inspur.com.rest/d" /etc/hosts
		echo "$ip iops.inspur.com.rest" >> /etc/hosts
		local network_card_name=`ip addr | grep $ip | awk '{print $NF}'`
		sed -i "/iops-/d" /etc/hosts
		echo "$ip iops-$network_card_name" >> /etc/hosts
	
		local ifcifg_file=`find /etc/sysconfig/network-scripts/* | xargs grep -ri "$ip" | cut -d ':' -f1`
		ifcifg_file=${ifcifg_filei%:*}
		if [[ ! -z $ifcifg_file ]]
		then
			local gateway=`cat $ifcifg_file | grep -i gateway | cut -d "=" -f2`
			if [[ ! -z $gateway ]]
			then
				local gateway_info=`echo ${gateway//\./-}`
				echo "$gateway iops-$gateway_info" >> /etc/hosts
			else
				echo "the network card configuration file for the ip ( $ip )  has no gateway info ,please check your configuration file in /etc/sysconfig/network-scripts folder ."
				exit 1
			fi
		fi
	fi
}
function removesame(){
    local old=$*
    local new=
    for num in $old
    do
        if [[ `echo $new |grep -w $num`x = x ]]
        then
            new=$new" "$num
        fi
    done
    echo $new
}


if [[ -z `cat /etc/hosts | grep incloudos` ]]
then
	echo
	myecho $RED "not inclouos in /etc/hosts , maybe icmp not installed in the system , please check it"
	echo
	exit 1
fi

localIPS=`ip addr | grep inet | grep -v inet6 | grep -v 127.0.0.1  | awk '{print $2}' | cut -d '/' -f1`
local_IPs_Str=${localIPS[*]}
IFS=" "
local_IPs_Str_Array=($local_IPs_Str)
local_IPs_Str_Num=${#local_IPs_Str_Array[@]}


need_Update_hosts=false
hostname=`hostname`
hosts_hostname_IPs=`cat /etc/hosts | grep $hostname | awk '{print $1}' | grep -v $hostname`
newIPS=`removesame $hosts_hostname_IPs`
if [[ "$newIPS"x != "x" ]]
then
	for ip in $newIPS
	do
	        if [[ ! $localIPS =~ $ip ]]
	        then
			echo
	                myecho $GREEN "hostname ip in /etc/hosts is different with system ip , we need update hostname ip in /etc/hosts"
			echo
			need_Update_hosts=true
	                break
	        fi
	done
fi

if [[ "$need_Update_hosts" = "true" ]]
then
	if [[ $local_IPs_Str_Num -gt 1 ]]
	then
        	myecho $GREEN "the system has "$local_IPs_Str_Num" ip,please choice one as icmp ip"
		echo
		myecho $GREEN "the system ip is "$local_IPs_Str
		ip_option_str=""
		for ((i=0;i<$local_IPs_Str_Num;i++))
		do
			ip_option_str=$ip_option_str" "$i
			myecho $GREEN "choice[ "$i" ] : "${local_IPs_Str_Array[$i]}
		done
		ip_option=""
                while [[ "$ip_option"x = x ]]
                do
                    echo
                    myecho $GREEN "please input your ip option, for example 0  ."
                    read -e ip_option
		    if [[ ! $ip_option_str =~ $ip_option ]]
	            then
			echo "input error,please input again"
			ip_option=""
			echo
			for ((i=0;i<$local_IPs_Str_Num;i++))
	                do
        	                ip_option_str=$ip_option_str" "$i
	                        myecho $GREEN "choice[ "$i" ] : "${local_IPs_Str_Array[$i]}
	                done
		    fi
                done
		`replace_host_ip ${local_IPs_Str_Array[$ip_option]}`
	else
		`replace_host_ip ${local_IPs_Str_Array[0]}`
	fi
fi



tomcatdirname=inspurtomcat
tomcat=/usr/local/$tomcatdirname
dubbo_service_root_dir=/opt/incloudos
#serviceVersion=service-5.0-1-1.0-0-0-SNAPSHOT

warIncloudosConfig=WEB-INF/classes/incloudConfig.properties
serviceIncloudosConfig=conf/incloudConfig.properties
serviceAddrfile=serviceAddr.properties

isReplaceZookeeper=
zookeeper_server=
while [ -z "$isReplaceZookeeper" ] ;do
        myecho $GREEN "whether to replace the zookeeper IP ? y or n"
        read -e isReplaceZookeeper
done
if [ $isReplaceZookeeper = "y" ]
then
	zookeeper_server=""
	while [ "$zookeeper_server"x = x ]
	do
		myecho $GREEN "> please input your zookeeper server ip!"
		myecho $GREEN "> if your zookeeper server is single node, for example : 192.168.1.1:2181 ."
		myecho $GREEN "> if your zookeeper server is distributed node, for example three nodes : 192.168.1.1:2181,192.168.1.2:2181,192.168.1.3:2181 ."
		read -e zookeeper_server

		if [[ ! -z $zookeeper_server ]]
		then
			IFS=","
		        for ip in ${zookeeper_server[@]}
		        do
		                echo $ip | grep "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\:2181$" > /dev/null
		                if [[ $? = 1 ]]
		                then
		                        myecho $RED "your input zookeeper ip has error,please check and reinput zookeeper ip  ."
					zookeeper_server=""
		                fi
		        done
		fi
        done

	if [[ -d /usr/local/inspurtomcat/webapps/ ]]
	then
		find /usr/local/inspurtomcat/webapps/ -name incloudConfig.properties | grep classes | xargs sed -i "s/dubbo\.registry\.address=.*/dubbo\.registry\.address=$zookeeper_server/g"
	fi
	if [[ -d /opt/incloudos/ ]]
        then
		find /opt/incloudos/ -name incloudConfig.properties | grep conf | xargs sed -i "s/dubbo\.registry\.address=.*/dubbo\.registry\.address=$zookeeper_server/g"
	fi
else
	myecho $GREEN "we will do not replace the zookeeperServer IP!"
fi

echo
myecho $RED "-----------(: this id dividing line :)-------------"
echo

isReplaceRabbitMQ=
rabbitmq_server=
while [ -z "$isReplaceRabbitMQ" ]
do
        myecho $GREEN "whether to replace the RabbitMQ IP ? y or n"
        read -e isReplaceRabbitMQ
done

if [ $isReplaceRabbitMQ = "y" ]
then
	rabbitmq_server=""
	while [ "$rabbitmq_server"x = x ]
	do
		myecho $GREEN "> please input your RabbitMQ server ip!"
		myecho $GREEN "> for example : 192.168.1.1."
		read -e rabbitmq_server
		if [[ `validate_ip $rabbitmq_server` -eq 1 ]]
                then    
                        myecho $RED  "your input ip info has error , please check and reinput ip ."
                        rabbitmq_server=""
                fi
        done
	
	find /usr/local/inspurtomcat/webapps/ -name incloudConfig.properties | grep classes | xargs sed -i 's/rabbitmq\.addr=.*/rabbitmq\.addr='${rabbitmq_server}'/g'
        find /opt/incloudos/ -name incloudConfig.properties | grep conf | xargs sed -i 's/rabbitmq\.addr=.*/rabbitmq\.addr='${rabbitmq_server}'/g' 

else
	myecho $GREEN "we will do not replace the RabbitMQ IP!"
fi

echo
myecho $RED "-----------(: this id dividing line :)-------------"
echo

isReplaceRabbitMQUser=
rabbitmq_username=
rabbitmq_password=
while [ -z "$isReplaceRabbitMQUser" ]
do
        myecho $GREEN "whether to replace the RabbitMQ username and password ? y or n"
        read -e isReplaceRabbitMQUser
done

if [ $isReplaceRabbitMQUser = "y" ]
then
	while [ -z "$rabbitmq_username" ]
	do
		myecho $GREEN "> please input your RabbitMQ username!"
		myecho $GREEN "> for example : admin."
		read -e rabbitmq_username
        done
	while [ -z "$rabbitmq_password" ] ;do
		myecho $GREEN "> please input your RabbitMQ password!"
		myecho $GREEN "> for example : password."
		read -e rabbitmq_password
        done

	find /usr/local/inspurtomcat/webapps/ -name incloudConfig.properties | grep classes | xargs sed -i 's/rabbitmq\.user=.*/rabbitmq\.user='${rabbitmq_username}'/g'
	find /usr/local/inspurtomcat/webapps/ -name incloudConfig.properties | grep classes | xargs sed -i 's/rabbitmq\.pass=.*/rabbitmq\.pass='${rabbitmq_password}'/g'
        
	find /opt/incloudos/ -name incloudConfig.properties | grep conf | xargs sed -i 's/rabbitmq\.user=.*/rabbitmq\.user='${rabbitmq_username}'/g'
        find /opt/incloudos/ -name incloudConfig.properties | grep conf | xargs sed -i 's/rabbitmq\.pass=.*/rabbitmq\.pass='${rabbitmq_password}'/g'

else
	myecho $GREEN "we will do not replace the RabbitMQ username password!"
fi

echo
myecho $RED "-----------(: this id dividing line :)-------------"
echo

isReplaceMysql=
mysql_server=
while [ -z "$isReplaceMysql" ]
do
        myecho $GREEN "whether to replace the mysql IP ? y or n"
        read -e isReplaceMysql
done

if [ $isReplaceMysql = "y" ]
then
	mysql_server=""
	while [ "$mysql_server"x = x ]
	do
		myecho $GREEN "> please input your mysql server ip!"
		myecho $GREEN "> for example : 192.168.1.1."
		read -e mysql_server
		if [[ `validate_ip $mysql_server` -eq 1 ]]
		then
			myecho $RED  "your input ip info has error , please check and reinput ip ."
			mysql_server=""
		fi
        done

	find /usr/local/inspurtomcat/webapps/ -name incloudConfig.properties | grep classes | xargs sed -i 's/mysql.*cloudos/mysql:\/\/'${mysql_server}':3306\/cloudos/g'
        find /opt/incloudos/ -name incloudConfig.properties | grep conf | xargs sed -i 's/mysql.*cloudos/mysql:\/\/'${mysql_server}':3306\/cloudos/g'

else
	myecho $GREEN "we will do not replace the Mysql IP!"
fi

echo
myecho $RED "-----------(: this id dividing line :)-------------"
echo

isReplace_iauth=
iauth_address=
while [ -z "$isReplace_iauth" ]
do
       myecho $GREEN "whether to replace the iauth IP ? y or n"
       read -e isReplace_iauth
done

if [ $isReplace_iauth = "y" ]
then
	iauth_address=""
	while [ "$iauth_address"x = x ]
	do
		myecho $GREEN "> please input your iauth ip !"
		myecho $GREEN "> for example : 192.168.1.1."
		read -e iauth_address
		if [[ `validate_ip $iauth_address` -eq 1 ]]
                then
                	myecho $RED  "your input ip info has error , please check and reinput ip ."
                	iauth_address=""
		fi
        done

	#find /usr/local/inspurtomcat/webapps/ -name incloudConfig.properties | grep classes | xargs sed -i '/iauth.*http.*8080/d'
	#find /usr/local/inspurtomcat/webapps/ -name incloudConfig.properties | grep classes | xargs sed -i '$a\iauth=http;$iauth_address;8080;iauth;inspur'
        #find /opt/incloudos/ -name incloudConfig.properties | grep conf | xargs sed -i '/iauth.*http.*8080/d'
        #find /opt/incloudos/ -name incloudConfig.properties | grep conf | xargs sed -i '$a\iauth=http;$iauth_address;8080;iauth;inspur'
	if [[ -d /usr/local/inspurtomcat/webapps ]]
	then
		sed -i "s/iauth=http;.*;8080;/iauth=http;$iauth_address;8080;/g" /usr/local/inspurtomcat/webapps/*/WEB-INF/classes/incloudConfig.properties
	fi
	if [[ -d /opt/incloudos ]]
        then
		sed -i "s/iauth=http;.*;8080/iauth=http;$iauth_address;8080/g" /opt/incloudos/*/conf/incloudConfig.properties
	fi
else
	myecho $GREEN "we will do not replace the iauth IP !"
fi

echo
myecho $RED "-----------(: this id dividing line :)-------------"
inspurtomcat_path=`ps -ef | grep inspurtomcat/bin/bootstrap.jar | grep -v grep | awk '{print $(NF-3)}' | cut -d "=" -f2`

isReplace_ui_serviceAddr=
serviceAddr_ui_address=""
while [ -z "$isReplace_ui_serviceAddr" ]
do
       myecho $GREEN "whether to replace the UI serviceAddr IP ? y or n"
       read -e isReplace_ui_serviceAddr
done


if [[ ! -z $inspurtomcat_path  ]]
then
	if [[ $isReplace_ui_serviceAddr =~ "y" ]]
	then
		
		while [ "$serviceAddr_ui_address"x = x ]
	        do
	                myecho $GREEN "> please input your UI serviceAddr  ip!"
	                myecho $GREEN "> for example : 192.168.1.1."
	                read -e serviceAddr_ui_address
			if [[ `validate_ip $serviceAddr_ui_address` -eq 1 ]]
			then
				myecho $RED  "your input ip info has error , please check and reinput ip ."
				serviceAddr_ui_address=""
			fi
	        done

		if [[ -d $inspurtomcat_path/webapps ]]
	        then
			if [[ -e $inspurtomcat_path/webapps/icm/serviceAddr.properties ]]
			then
		                sed -i '/'icm'=/d' $inspurtomcat_path/webapps/icm/serviceAddr.properties
		                sed -i '/'ism'=/d' $inspurtomcat_path/webapps/icm/serviceAddr.properties
	        	        sed -i '/'websocketMonitor'=/d' $inspurtomcat_path/webapps/icm/serviceAddr.properties
	                	echo  "icm=$serviceAddr_ui_address" >> $inspurtomcat_path/webapps/icm/serviceAddr.properties
		                echo  "ism=$serviceAddr_ui_address" >> $inspurtomcat_path/webapps/icm/serviceAddr.properties
	        	        echo  "websocketMonitor=$serviceAddr_ui_address" >> $inspurtomcat_path/webapps/icm/serviceAddr.properties
			fi
			if [[ -e $inspurtomcat_path/webapps/ism/serviceAddr.properties ]]
                        then
				sed -i '/'icm'=/d' $inspurtomcat_path/webapps/ism/serviceAddr.properties
                                sed -i '/'ism'=/d' $inspurtomcat_path/webapps/ism/serviceAddr.properties
                                sed -i '/'websocketMonitor'=/d' $inspurtomcat_path/webapps/ism/serviceAddr.properties
                                echo  "icm=$serviceAddr_ui_address" >> $inspurtomcat_path/webapps/ism/serviceAddr.properties
                                echo  "ism=$serviceAddr_ui_address" >> $inspurtomcat_path/webapps/ism/serviceAddr.properties
                                echo  "websocketMonitor=$serviceAddr_ui_address" >> $inspurtomcat_path/webapps/ism/serviceAddr.properties
                        fi
	        fi

	fi
fi


echo
myecho $RED "-----------(: this id dividing line :)-------------"
isReplace_icompute_vncProxyIP=
icompute_vncProxyIP_address=""
while [ -z "$isReplace_icompute_vncProxyIP" ]
do
       myecho $GREEN "whether to replace the icompute vncProxyIP ? y or n"
       read -e isReplace_icompute_vncProxyIP
done
if [[ $isReplace_icompute_vncProxyIP =~ "y" ]]
then
	while [ "$icompute_vncProxyIP_address"x = x ]
        do
            myecho $GREEN "> please input the icompute vncProxyIP !"
            myecho $GREEN "> for example : 192.168.1.1 "
            read -e icompute_vncProxyIP_address
			if [[ `validate_ip $icompute_vncProxyIP_address` -eq 1 ]]
			then
				myecho $RED  "your input ip info has error , please check and reinput ip ."
				icompute_vncProxyIP_address=""
			fi
        done
	if [[ -d $inspurtomcat_path/webapps ]]
    then
		if [[ -e $inspurtomcat_path/webapps/icompute/WEB-INF/classes/incloudConfig.properties ]]
		then
        	sed -i '/'vncProxyIp'=/d' $inspurtomcat_path/webapps/icompute/WEB-INF/classes/incloudConfig.properties
        	echo  "vncProxyIp=$icompute_vncProxyIP_address" >> $inspurtomcat_path/webapps/icompute/WEB-INF/classes/incloudConfig.properties
        fi
	fi
fi

echo
myecho $GREEN "replace ip action finished !!!"
