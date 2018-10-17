#!/bin/sh
echo 'shengchan start execute restore mysql info >>>>' `date "+%Y-%m-%d %H:%M:%S"`
cd /usr/local
echo 'start mysqldump info>>>>' `date "+%Y-%m-%d %H:%M:%S"`
current=`date "+%Y-%m-%d %H:%M:%S"`
s1="/usr/local/cloudos_db_sc_all_"
s2=`date -d "$current" +%s`
s3=".sql"
mysqldump -h127.0.0.1 -uinspurCloudDB -pincloudosInspur2! cloudos_db --default-character-set=utf8 --hex-blob --ignore-table=cloudos_db.t_rs_usg_history --ignore-table=cloudos_db.t_rs_vm_status_history --force > ${s1}${s2}${s3} --single-transaction
tar -zcvf /usr/local/cloudos_db_sc_all_${s2}.tar.gz ${s1}${s2}${s3};
cp -rf ${s1}${s2}${s3} /usr/local/cloudos_db_sc_all.sql;
#tar -zcvf cloudos_db_sc_all.tar.gz cloudos_db_sc_all.sql
gzname="cloudos_db_sc_all_${s2}.tar.gz";
#sqlname="cloudos_db_sc_all.tar.gz";
echo 'end mysqldump info >>>' `date "+%Y-%m-%d %H:%M:%S"`
echo 'start ftp info >>>>' `date "+%Y-%m-%d %H:%M:%S"`
ftp -v -n 10.84.150.22 << EOF
user administrator 123456
binary
cd csdb
lcd ./
prompt
put $gzname
put cloudos_db_sc_all.sql
bye
EOF
echo 'end ftp info >>>>' `date "+%Y-%m-%d %H:%M:%S"`
rm -rf ${s1}${s2}${s3};
rm -rf /usr/local/cloudos_db_sc_all.sql
echo 'shengchan end execute restore mysql info >>>>' `date "+%Y-%m-%d %H:%M:%S"`
