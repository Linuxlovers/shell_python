#var=`date +%Y%m%d%H%M`
scview_array=('10.84.150.47','10.0.28.233','10.84.150.57')
is_httpIP='10.0.2.45'
scview_service_array=('ibase-service-5.2-1-gd2-1.0-0-0-SNAPSHOT','icharge-service-5.2-1-gd2-1.0-0-0-SNAPSHOT','icompute-service-5.2-1-gd2-1.0-0-0-SNAPSHOT','imonitor-service-5.2-1-gd2-1.0-0-0-SNAPSHOT','inetwork-service-5.2-1-gd2-1.0-0-0-SNAPSHOT','istorage-service-5.2-1-gd2-1.0-0-0-SNAPSHOT','iworkflow-service-5.2-1-gd2-1.0-0-0-SNAPSHOT')
is_scviewip=0
service_modules=`ls service/`
currentIP=`ifconfig ens160 | grep "inet " | awk '{ print $2}'`
echo 'current ip is :'$currentIP

for((i=0;i<${#scview_array[@]};i++))
do
    echo -e 'shengchan data view ip is :'${scview_array[$i]}
done

if echo "${scview_array[@]}" | grep -w "$currentIP" &>/dev/null; then
    is_scviewip=1
    echo 'current ip is scviewip'
fi

if [ $currentIP == $is_httpIP ]; then
    echo "current ip is 10_0_2_45! backup begin !"
    rm -rf /root/upgrade/inspurtomcat.tar
    tar -cf /root/upgrade/inspurtomcat.tar /usr/local/inspurtomcat/
    echo 'backup end'
else
    echo "current ip is not 10_0_2_45! backup begin !"
    rm -rf /root/upgrade/incloudos.tar
    rm -rf /root/upgrade/inspurtomcat.tar
    tar -cf /root/upgrade/incloudos.tar /opt/incloudos/
    tar -cf /root/upgrade/inspurtomcat.tar /usr/local/inspurtomcat/
    echo 'backup end'
fi

if [ $is_scviewip -eq 0 ]; then
    echo "current ip is not scviewip!"
    rm -rf rest/*-gd
else
    echo "current ip is scviewip!"
    #rm -rf rest/icm rest/ism rest/icompute rest/iworkflow rest/ibase
    cd rest/
    rm -rf `ls | grep -v \\\-gd`
    cd ..
    for mod in $service_modules
    do
        echo 'replace module is '$mod
        if echo "${scview_service_array[@]}" | grep -w "$mod" &>/dev/null; then
            echo $mod 'is replace module in scview'
        else
            echo $mod 'is not replace module in scview'
            rm -rf service/$mod
        fi
    done

fi
if [ $currentIP == $is_httpIP ]; then
    \cp -rf rest/icm /usr/local/inspurtomcat/webapps/ 
    \cp -rf rest/ism /usr/local/inspurtomcat/webapps/ 
else
    \cp -rf rest/* /usr/local/inspurtomcat/webapps/ 
    \cp -rf service/* /opt/incloudos/
fi
#\cp -rf incloudos_service /etc/init.d/incloudos_service
#systemctl daemon-reload
