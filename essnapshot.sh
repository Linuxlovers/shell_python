var=`date +%Y%m%d%H%M`
#curl -XPUT  http://127.0.0.1:9200/_snapshot/my_backup/snapshot_$var
curl -XPUT  http://127.0.0.1:9200/_snapshot/my_backup/snapshot_$var?wait_for_completion=true
#curl -XPUT  http://127.0.0.1:9200/_snapshot/jinhd_backup/snapshot_$var
