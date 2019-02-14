1.上传相关升级文件
	测试环境（232），上传ceshi中的文件到/usr/local中
	生产环境（239），上传shengchan中的文件到/usr/local中
	生产测试都需要上传 ftp-0.17-54.el6.x86_64.rpm到/usr/local中
2.安装ftp客户端 yum -y install /usr/local/ftp-0.17-54.el6.x86_64.rpm
3.安装完成之后删除文件ftp-0.17-54.el6.x86_64.rpm rm -rf /usr/local/ftp-0.17-54.el6.x86_64.rpm
4.授权文件 
chmod a+x /usr/local/auto_backup_script.sh /usr/local/auto_restore_script.sh
5.修改文件vim /usr/local/auto_backup_script.sh，主要是修改ftp地址，可以参考 vim /opt/incloudos/ibase-service-5.2-1-gd2-1.0-0-0-SNAPSHOT/conf/incloudConfig.properties

ftp -v -n 10.84.137.251 << EOF
user cmpii 1qaz@WSX
binary
cd cmpii-oa
lcd ./
prompt
put $gzname
put cloudos_db_cs_t_wf_business_info.sql
bye
EOF

6.修改配置文件vim /usr/local/auto_restore_script.sh，主要是修改ftp地址，可以参考 vim /opt/incloudos/ibase-service-5.2-1-gd2-1.0-0-0-SNAPSHOT/conf/incloudConfig.properties

ftp -v -n 10.84.137.251  << EOF
user cmpii 1qaz@WSX
binary
cd cmpii-sc
lcd ./
prompt
get cloudos_db_sc_all.sql
bye
EOF


7.添加自启动vim /etc/crontab
*/50 * * * * root sh /usr/local/auto_backup_script.sh >> /usr/local/auto_backup_script.log &
*/50 * * * * root sh /usr/local/auto_restore_script.sh >> /usr/local/auto_restore_script.log &
8.重启crontab
systemctl restart crond
