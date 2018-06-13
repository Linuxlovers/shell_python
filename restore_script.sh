#!/bin/sh
echo 'drop database if exists cloudos_db_new;create database cloudos_db_new;grant all privileges on cloudos_db_new.* to inspurCloudDB@"%" identified by "incloudosInspur2!";flush privileges;'  | mysql -uroot -p123456a? -h10.84.150.47
mysql -uroot -p123456a? -h10.84.150.47 cloudos_db_new < /usr/local/cloudos_db_sc_all-download.sql