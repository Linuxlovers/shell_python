#!/bin/sh
echo 'shengchan start execute restore mysql info >>>>' `date "+%Y-%m-%d %H:%M:%S"`
cd /usr/local/
echo 'start get cloudos_db_cs_t_wf_business_info.sql from ftp >>>>' `date "+%Y-%m-%d %H:%M:%S"`
ftp -v -n 10.0.240.232 << EOF
user cmpii 1qaz@WSX
binary
cd cmpii-oa
lcd ./
prompt
get cloudos_db_cs_t_wf_business_info.sql
bye
EOF
echo 'end get cloudos_db_cs_t_wf_business_info.sql from ftp >>>>' `date "+%Y-%m-%d %H:%M:%S"`
#tar -zxvf cloudos_db_cs_t_wf_business_info.tar.gz
mv -f cloudos_db_cs_t_wf_business_info.sql cloudos_db_cs_t_wf_business_info-download.sql
mysql -uroot -p123456a? cloudos_db < /usr/local/cloudos_db_cs_t_wf_business_info-download.sql
echo 'ceshihuanjing end execute restore mysql info >>>>' `date "+%Y-%m-%d %H:%M:%S"`
