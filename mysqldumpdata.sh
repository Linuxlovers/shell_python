#var=`date +%Y%m%d%H%M`
var='0'
mysqldump -uroot -p123456a? --single-transaction  --databases cloudos_db > /home/icm/mysql.bak_$var.sql
scp -r /home/icm/mysql.bak_$var.sql root@10.88.25.232:/home/icm/
#/home/icm/scpfilenopasswd.sh 10.88.25.232 root Windows2008@ebscn /home/icm/mysql.bak_$var.sql /home/icm/

