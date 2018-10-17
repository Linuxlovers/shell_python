#!/bin/sh
echo 'ceshihuanjing start execute backup mysql info >>>>' `date "+%Y-%m-%d %H:%M:%S"`
echo 'start mysqldump info >>>>' `date "+%Y-%m-%d %H:%M:%S"`
current=`date "+%Y-%m-%d %H:%M:%S"`
s1="/usr/local/cloudos_db_cs_t_wf_business_info_"
s2=`date -d "$current" +%s`
s3=".sql"
cd /usr/local/
mysqldump -h127.0.0.1 -uinspurCloudDB -pincloudosInspur2! --databases cloudos_db --tables t_wf_business_info > ${s1}${s2}${s3} --single-transaction
mysqldump -h127.0.0.1 -uinspurCloudDB -pincloudosInspur2! --databases cloudos_db --tables t_wf_gdzq_system_info >> ${s1}${s2}${s3} --single-transaction
mysqldump -t -h127.0.0.1 -uinspurCloudDB -pincloudosInspur2! --databases cloudos_db --tables t_ba_project_expand >> ${s1}${s2}${s3}
mysqldump -h127.0.0.1 -uinspurCloudDB -pincloudosInspur2! --databases cloudos_db --tables t_bomc_vm_business --no-create-info --skip-triggers >> ${s1}${s2}${s3}
mysql -uinspurCloudDB -pincloudosInspur2! <<EOF
use cloudos_db;
delete from t_bomc_vm_business;
delete from t_ba_project_expand;
EOF
tar -zcvf /usr/local/cloudos_db_cs_t_wf_business_info_${s2}.tar.gz ${s1}${s2}${s3};
cp -rf ${s1}${s2}${s3} /usr/local/cloudos_db_cs_t_wf_business_info.sql;
#tar -zcvf cloudos_db_cs_t_wf_business_info.tar.gz cloudos_db_cs_t_wf_business_info.sql;
gzname="cloudos_db_cs_t_wf_business_info_${s2}.tar.gz";
#sqlname="cloudos_db_cs_t_wf_business_info.tar.gz";
echo 'end mysqldump info >>>>' `date "+%Y-%m-%d %H:%M:%S"`
echo 'start ftp info >>>>' `date "+%Y-%m-%d %H:%M:%S"`
ftp -v -n 10.84.150.22 << EOF
user administrator 123456
binary
cd csdb
lcd ./
prompt
put $gzname
put cloudos_db_cs_t_wf_business_info.sql
bye
EOF
echo 'end ftp info >>>>' `date "+%Y-%m-%d %H:%M:%S"`
rm -rf ${s1}${s2}${s3};
rm -rf /usr/local/cloudos_db_cs_t_wf_business_info.sql;
echo 'ceshihuanjing end execute backup mysql info >>>>' `date "+%Y-%m-%d %H:%M:%S"`
