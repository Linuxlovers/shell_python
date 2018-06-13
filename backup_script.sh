#!/bin/sh
mysqldump -h127.0.0.1 -uinspurCloudDB -pincloudosInspur2! --databases cloudos_db --tables t_wf_business_info > /usr/local/cloudos_db_cs_t_wf_business_info.sql --single-transaction
 mysqldump -h127.0.0.1 -uinspurCloudDB -pincloudosInspur2! --databases cloudos_db --tables t_bomc_vm_business --no-create-info >> /usr/local/cloudos_db_cs_t_wf_business_info.sql
 mysql -uinspurCloudDB -pincloudosInspur2! <<EOF
use cloudos_db;
delete from t_bomc_vm_business;
EOF
