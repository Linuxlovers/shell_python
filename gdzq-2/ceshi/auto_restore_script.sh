#!/bin/sh
is_create_database=0
echo 'ceshihuanjing start execute restore mysql info >>>>' `date "+%Y-%m-%d %H:%M:%S"`
cd /usr/local/
viewip=10.84.150.57
echo 'start get cloudos_db_sc_all.sql from ftp >>>>' `date "+%Y-%m-%d %H:%M:%S"`
ftp -v -n 10.84.150.22 << EOF
user administrator 123456
binary
cd csdb
lcd ./
prompt
get cloudos_db_sc_all.sql
bye
EOF
echo 'end get cloudos_db_sc_all.sql from ftp >>>>' `date "+%Y-%m-%d %H:%M:%S"`
echo 'start restore info by mysql command >>>>' `date "+%Y-%m-%d %H:%M:%S"`
#tar -zxvf cloudos_db_sc_all.tar.gz
mv -f cloudos_db_sc_all.sql cloudos_db_sc_all-download.sql;
sed -e 's/DEFINER[]*=[]*[^*]*\*/\*/' /usr/local/cloudos_db_sc_all-download.sql > /usr/local/cloudos_db_sc_all-test.sql
rm -f /usr/local/cloudos_db_sc_all-download.sql;
mv /usr/local/cloudos_db_sc_all-test.sql /usr/local/cloudos_db_sc_all-download.sql;
touch /usr/local/cloudos_db_sc_all-download.sql;
chmod 755 /usr/local/cloudos_db_sc_all-download.sql;
for i in $(mysql  -h$viewip -uroot -p123456a? -Bse "select trx_mysql_thread_id from information_schema.innodb_trx;" | awk '{print $1}');do mysql  -h$viewip -uroot -p123456a? -e "kill $i";done 
for i in $(mysql  -h$viewip -uinspurCloudDB -pincloudosInspur2! -Bse "show processlist" | awk '{print $1}');do mysql  -h$viewip -uinspurCloudDB -pincloudosInspur2! -e "kill $i";done
if [ $is_create_database -eq 1 ]; then
    echo 'drop database if exists cloudos_db_new;create database cloudos_db_new;grant all privileges on cloudos_db_new.* to inspurCloudDB@"%" identified by "incloudosInspur2!";flush privileges;'  | mysql -uinspurCloudDB -pincloudosInspur2! -h$viewip
fi
mysql -uinspurCloudDB -pincloudosInspur2! -h$viewip cloudos_db_new < /usr/local/cloudos_db_sc_all-download.sql
echo 'end restore info by mysql command >>>>' `date "+%Y-%m-%d %H:%M:%S"`
echo 'ceshihuanjing end execute restore mysql info >>>>' `date "+%Y-%m-%d %H:%M:%S"`
