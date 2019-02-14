#!/bin/sh
echo 'shengchan start execute restore mysql info >>>>' `date "+%Y-%m-%d %H:%M:%S"`
cd /usr/local/
echo 'start get cloudos_db_cs_t_wf_business_info.sql from ftp >>>>' `date "+%Y-%m-%d %H:%M:%S"`
ftp -v -n 10.84.150.22 << EOF
user administrator 123456
binary
cd csdb
lcd ./
prompt
get cloudos_db_cs_t_wf_business_info.sql
bye
EOF
echo 'end get cloudos_db_cs_t_wf_business_info.sql from ftp >>>>' `date "+%Y-%m-%d %H:%M:%S"`
#tar -zxvf cloudos_db_cs_t_wf_business_info.tar.gz
mv -f cloudos_db_cs_t_wf_business_info.sql cloudos_db_cs_t_wf_business_info-download.sql
# dump tables info before delete
mysqldump -h127.0.0.1 -uinspurCloudDB -pincloudosInspur2! \
          --no-create-info \
          --single-transaction \
          --skip-triggers \
          --databases cloudos_db \
          --tables t_ba_configure_detail \
                   t_ba_project_configure \
                   t_ba_project_plan \
                   t_rs_resource_template_history \
                   t_rs_resource_template \
                   t_wf_gdzq_system_info \
                   t_wf_business_info \
          > deleted_tables_data_backup.sql
mysql -uinspurCloudDB -pincloudosInspur2! <<EOF
use cloudos_db;
delete from t_ba_configure_detail;
delete from t_ba_project_configure;
delete from t_ba_project_plan;
delete from t_rs_resource_template_history;
delete from t_rs_resource_template;
delete from t_wf_gdzq_system_info;
delete from t_wf_business_info;
EOF
mysql -uroot -p123456a? cloudos_db < /usr/local/cloudos_db_cs_t_wf_business_info-download.sql
echo 'ceshihuanjing end execute restore mysql info >>>>' `date "+%Y-%m-%d %H:%M:%S"`
