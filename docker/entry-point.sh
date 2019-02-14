#!/bin/bash
set -e
	
WAR_NAME="workmanager.war"
WAR_FILE="/tmp/war/${WAR_NAME}"
WAR_DIR="/tmp/war"
TOMCAT_HOME="/opt/tomcat"
WAR_UNZIP_DIR="/tmp/war/workmanager"
#custom
CHANGER_MYBATIS_PROPERTIES_FILE="${WAR_UNZIP_DIR}/WEB-INF/classes/mybatis-config.properties"
CHANGER_SERVER_PROPERTIES_FILE="${WAR_UNZIP_DIR}/WEB-INF/classes/server.properties"
CHANGER_LOG_FILE="${WAR_UNZIP_DIR}/WEB-INF/classes/log4j2.xml"
function updateMyBatisProperties(){
  if [ 0"$POSTGRES_URL" = "0" ]; then
    echo "POSTGRES_URL does not exist,error"
	exit 1
  fi
  if [ 0"$POSTGRES_DATABASE_USERNAME" = "0" ]; then
    echo "use default mysql database user name"
	POSTGRES_DATABASE_USERNAME="postgres"
  fi
  if [ 0"$POSTGRES_DATABASE_PASSWORD" = "0" ]; then
    echo "use default mysql database password"
	POSTGRES_DATABASE_PASSWORD="archdemo"
  fi
  POSTGRES_DB_URL="mybatis.main.jdbcUrl=${POSTGRES_URL}"
  POSTGRES_DB_USERNAME="mybatis.main.user=${POSTGRES_DATABASE_USERNAME}"
  POSTGRES_DB_PASSWORD="mybatis.main.password=${POSTGRES_DATABASE_PASSWORD}"
  sed -i "s|^mybatis\.main\.jdbcUrl=.*$|${POSTGRES_DB_URL}|" $CHANGER_MYBATIS_PROPERTIES_FILE
  sed -i "s|^mybatis\.main\.user=.*$|${POSTGRES_DB_USERNAME}|" $CHANGER_MYBATIS_PROPERTIES_FILE
  sed -i "s|^mybatis\.main\.password=.*$|${POSTGRES_DB_PASSWORD}|" $CHANGER_MYBATIS_PROPERTIES_FILE 
}
function updateServerProperties(){
#taskReportMessageUrl=http://10.10.70.94:7091/taskReportMessage
#sendCommentMessageUrl=http://10.10.70.94:7091/sendCommentMessage
#restTaskReportMessageUrl=http://10.10.70.94:7091/restTaskReportMessage

 if [ 0"$TASK_REPORT_MESSAGE_URL" = "0" ]; then
    echo "TASK_REPORT_MESSAGE_URL does not exist,error"
	exit 1
  fi
  TASK_REPORT_MESSAGE_URL_LINE="taskReportMessageUrl=${TASK_REPORT_MESSAGE_URL}"
  sed -i "s|^taskReportMessageUrl=.*$|${TASK_REPORT_MESSAGE_URL_LINE}|" $CHANGER_SERVER_PROPERTIES_FILE
 
 if [ 0"$SEND_COMMON_MESSAGE_URL" = "0" ]; then
    echo "SEND_COMMON_MESSAGE_URL does not exist,error"
	exit 1
  fi
  SEND_COMMON_MESSAGE_URL_LINE="sendCommentMessageUrl=${SEND_COMMON_MESSAGE_URL}"
  sed -i "s|^sendCommentMessageUrl=.*$|${SEND_COMMON_MESSAGE_URL_LINE}|" $CHANGER_SERVER_PROPERTIES_FILE
  
  if [ 0"$REST_TASK_REPORT_MESSAGE_URL" = "0" ]; then
    echo "REST_TASK_REPORT_MESSAGE_URL does not exist,error"
	exit 1
  fi
  REST_TASK_REPORT_MESSAGE_URL_LINE="restTaskReportMessageUrl=${REST_TASK_REPORT_MESSAGE_URL}"
  sed -i "s|^restTaskReportMessageUrl=.*$|${REST_TASK_REPORT_MESSAGE_URL_LINE}|" $CHANGER_SERVER_PROPERTIES_FILE
   
  #exportExcelPath=D:/Tomcat 8.5_Tomcat8_workmanage_8080/images/
  #headPortraitFilePath=E:/images/headportrait/
  if [ ! -d "/data/exportExcelPath" ]; then
     mkdir /data/exportExcelPath -p
  fi 
  if [ ! -d "/data/exportExcelPath" ]; then
     mkdir /data/headPortraitFilePath -p
  fi 
  sed -i "s|^exportExcelPath=.*$|exportExcelPath=/data/exportExcelPath|" $CHANGER_SERVER_PROPERTIES_FILE
  sed -i "s|^headPortraitFilePath=.*$|headPortraitFilePath==/data/headPortraitFilePath|" $CHANGER_SERVER_PROPERTIES_FILE
  
}

if [  -f "$WAR_FILE" ]; then 
    echo "first startup, init war file..."
	#unzip war
    cd $WAR_DIR
    mkdir -p $WAR_UNZIP_DIR	
	unzip -oq $WAR_NAME  -d $WAR_UNZIP_DIR
	updateMyBatisProperties
    updateServerProperties

    #move unziped war to tomcat webapp
	mv $WAR_UNZIP_DIR $TOMCAT_HOME/webapps -f
  
	rm $WAR_FILE -rf
	rm $WAR_UNZIP_DIR -rf
	echo "first startup, init war finished"
fi
echo "starting tomcat..."	
#start tomcat
/usr/local/bin/starttomcat.sh
exec "$@"

