#!/bin/bash
#@author sunliaodong
#@date 2018-04-28
currentDate=$(date "+%G-%m-%d %H:%M:%S")
mysql_user=root
mysql_password=123456a?
mysql_host=localhost
mail_table=cloudos_db.t_ba_email
send_to=1112
message_array=()
message_info="";
#0:不自动启动
#1：自动启动
autoRestartFlag=0
#sendMail
function sendMail(){
	#echo ${#message_array[@]}"sendMail function....."
	for((i=0;i<${#message_array[@]};i++))
	do
		#echo -e ${message_array[$i]}
		message_info="$message_info\n========================================================================================================\n${message_array[$i]}"
	done
	echo -e $message_info
	#写入mysql数据库
	insert_sql="INSERT INTO $mail_table VALUES (REPLACE(UUID(),'-',''), '$message_info', '$send_to', NULL, '[浪潮云海] 服务异常日志', NULL, NULL, 0, now(), now())"
	echo $insert_sql
	mysql -u$mysql_user -p$mysql_password -h$mysql_host -e  "${insert_sql}"
}

#check itself
if [[ ! -f /opt/icmp/checkBasicServicesAndSendMail.sh ]]
then
	# there is no  icmp shell
	message_array=("${message_array[@]}" "$currentDate>>>>:there is no  icmp shell")
	exit 1
fi

shellName=`basename $0`
ps | grep $shellName | grep -v grep > /dev/null 2>&1
if [[ $? -eq 0 ]]
then
	message_array=("${message_array[@]}" "$currentDate>>>>:Another instance is already running")
	exit 1
fi
#1.校验mysql服务是否正常，如果不正常需要邮件通知系统管理员
if [[ -f /usr/lib/systemd/system/mysqld.service  ]]
	then
	if [[ -z `ps -ef | grep mysqld | grep -v grep` ]]
	then
		if [[ "$autoRestartFlag" -eq 1 ]]
		then
			systemctl restart mysqld.service &
		fi
		message_array=("${message_array[@]}" "$currentDate>>>>:mysql服务异常，启动命令参考【systemctl restart mysqld.service &】")
	else
		#1.1.查看数据库主从复制状态，如果不正常需要邮件通知系统管理员
		mysql -u$mysql_user -p$mysql_password -h$mysql_host -e "show slave status\G"|grep "Slave_IO_Running"|awk '{if ($2!="Yes"){exit 1}}'
		if [ $? -eq 0 ];then
			#mysql -u$mysql_user -p$mysql_password -h$mysql_host -e "show slave status\G"|grep "Seconds_Behind_Master"
			echo "mysql主从复制正常"
		else
		    if [[ "$autoRestartFlag" -eq 1 ]]
			then
				mysql -u$mysql_user -p$mysql_password -h$mysql_host -e "start slave"
			fi
			message_array=("${message_array[@]}" "$currentDate>>>>:mysql主从复制服务异常，启动命令参考【mysql -u$mysql_user -p$mysql_password -h$mysql_host -e \"start slave\"】")
		fi
	fi
fi
#2.校验zookeeper服务是否正常，如果不正常需要邮件通知系统管理员
if [[ -f /usr/lib/systemd/system/zookeeper.service  ]]
then
	if [[ ! -z `systemctl status zookeeper.service | grep Active | grep failed` ]]
	then
		if [[ "$autoRestartFlag" -eq 1 ]]
		then
			systemctl restart zookeeper.service &
		fi
		message_array=("${message_array[@]}" "$currentDate>>>>:zookeeper服务异常，启动命令参考【systemctl restart zookeeper.service &】")
	fi
fi
#3.校验rabbitmq服务是否正常，如果不正常需要邮件通知系统管理员
if [[ -f /usr/lib/systemd/system/rabbitmq-server.service  ]]
then
	if [[ ! -z ` systemctl status rabbitmq-server.service  |  grep dead` ]]
	then
		if [[ "$autoRestartFlag" -eq 1 ]]
		then
			systemctl restart rabbitmq-server.service &
		fi
		message_array=("${message_array[@]}" "$currentDate>>>>:rabbitmq服务异常，启动命令参考【systemctl restart rabbitmq-server.service &】")
	fi
fi
#4.校验tomcat服务是否正常，，如果不正常需要邮件通知系统管理员
tomcatpath=`whereis inspurtomcat | awk '{print $2}'`
if [[ "$tomcatpath"x = x ]]
then
	tomcatpath=/usr/local/inspurtomcat
fi
if [[ -f /usr/lib/systemd/system/tomcat.service ]]
then
	if [[ ! -z `systemctl status tomcat.service | grep Active | grep failed` ]]
	then
		if [[ "$autoRestartFlag" -eq 1 ]]
		then
			systemctl restart tomcat.service &
		fi
		message_array=("${message_array[@]}" "$currentDate>>>>:tomcat服务异常，启动命令参考【systemctl restart tomcat.service &】")
	fi
fi
#5.校验shinken服务是否正常，如果不正常需要邮件通知系统管理员
if [[ -d /usr/local/shinken ]]
then
	if [[ ! -z `/etc/init.d/shinken status | grep FAILED` ]]
	then
		if [[ "$autoRestartFlag" -eq 1 ]]
		then
			/etc/init.d/shinken stop 
			/etc/init.d/npcd stop
			/bin/ps -ef | grep shinken-arbiter | cut -c 9-15 | xargs kill -s 9
			/bin/ps -ef | grep shinken-scheduler | cut -c 9-15 | xargs kill -s 9
			/bin/ps -ef | grep shinken-poller | cut -c 9-15 | xargs kill -s 9
			/bin/ps -ef | grep shinken-broker | cut -c 9-15 | xargs kill -s 9
			/bin/ps -ef | grep shinken-receiver | cut -c 9-15 | xargs kill -s 9
			/bin/ps -ef | grep shinken-reactionner | cut -c 9-15 | xargs kill -s 9
			/bin/chown shinken:shinken /usr/local/shinken/var/arbiterd.log
			/bin/chmod 777 /usr/local/shinken/var/arbiterd.log
			/etc/init.d/npcd start
			/etc/init.d/shinken start
		fi
		message_array=("${message_array[@]}" "$currentDate>>>>:shinken服务异常，启动命令参考【\n
			/etc/init.d/shinken stop \n
			/etc/init.d/npcd stop \n
			/bin/ps -ef | grep shinken-arbiter | cut -c 9-15 | xargs kill -s 9 \n
			/bin/ps -ef | grep shinken-scheduler | cut -c 9-15 | xargs kill -s 9 \n
			/bin/ps -ef | grep shinken-poller | cut -c 9-15 | xargs kill -s 9 \n
			/bin/ps -ef | grep shinken-broker | cut -c 9-15 | xargs kill -s 9 \n
			/bin/ps -ef | grep shinken-receiver | cut -c 9-15 | xargs kill -s 9 \n
			/bin/ps -ef | grep shinken-reactionner | cut -c 9-15 | xargs kill -s 9 \n
			/bin/chown shinken:shinken /usr/local/shinken/var/arbiterd.log \n
			/bin/chmod 777 /usr/local/shinken/var/arbiterd.log \n
			/etc/init.d/npcd start \n
			/etc/init.d/shinken start \n
		】")
	fi
fi
#6.校验redis服务是否正常，如果不正常需要邮件通知系统管理员
if [[ -f /etc/init.d/redis-server ]]
then
	if [[ -z `ps -ef | grep redis | grep -v grep | grep 6379` ]]
	then
		if [[ "$autoRestartFlag" -eq 1 ]]
		then
			/etc/init.d/redis-server stop
			/etc/init.d/redis-server start
			#redis-server /etc/redis/6379.conf
		fi
		message_array=("${message_array[@]}" "$currentDate>>>>:tomcat服务异常，启动命令参考【\n
			/etc/init.d/redis-server stop \n
			/etc/init.d/redis-server start \n
			如果启动时出现如下错误：/var/run/redis_6379.pid exists, process is already running or crashed \n
			请执行如下代码：redis-server /etc/redis/6379.conf
		】")
	fi
fi
#7.校验icmp service是否正常，如果不正常需要邮件通知系统管理员
modules=`ls /opt/incloudos/ | grep i*-service`
for mod in $modules
do
	if [[ ! -z `sh /opt/incloudos/$mod/bin/status.sh | grep stopped` ]]
	then
		if [[ "$autoRestartFlag" -eq 1 ]]
		then
			sh /opt/incloudos/$mod/bin/restart.sh &
		fi
		#echo ${#message_array[@]}
		#echo $mod
		message_array=("${message_array[@]}" "$currentDate>>>>:云海服务【$mod】异常，启动命令参考【/opt/incloudos/$mod/bin/restart.sh &】")
		#echo ${#message_array[@]}
	fi
done
sendMail