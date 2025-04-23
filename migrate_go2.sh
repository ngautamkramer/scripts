#!/bin/bash

#install pgsql extension for php
/usr/bin/sudo chmod -R +x postgres.service


#copy pgsql folder to /usr/local it contains postgres setup
/usr/bin/sudo cp -r pgsql /usr/local

#create data folder for postgresql where all data will be stored
/usr/bin/sudo mkdir -p /usr/local/pgsql/data
/usr/bin/sudo chmod -R +x /usr/local/pgsql
/usr/bin/sudo touch /usr/local/pgsql/plog.log


#assign user permissions to data and log file
/usr/bin/sudo chown -R $USER:$USER /usr/local/pgsql/data
/usr/bin/sudo chown -R $USER:$USER /usr/local/pgsql/plog.log


#initialize database
/usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data -U postgres -A trust -E UTF8

#start postgresql database
/usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data -l /usr/local/pgsql/plog.log start


#Change postgres user password and set PGPASSWORD for current session 
/usr/local/pgsql/bin/psql -U postgres -c "ALTER USER postgres WITH PASSWORD 'w0wAdm1n8'"
export PGPASSWORD='w0wAdm1n8'


#changed in pg_hba.conf for prompt password when use -U username
/usr/bin/sudo cp -r pg_hba.conf /usr/local/pgsql/data
/usr/bin/sudo chown -R $USER:$USER /usr/local/pgsql/data/pg_hba.conf


#restart postgresql database
/usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data -l /usr/local/pgsql/plog.log -m fast restart


#create database
/usr/local/pgsql/bin/createdb -U postgres wpg

#create roles and extension (for encrypt and descypt function like: mysql ASE)
/usr/local/pgsql/bin/psql -U postgres -d wpg -c "CREATE EXTENSION IF NOT EXISTS pgcrypto"


#create user and set permission
/usr/local/pgsql/bin/psql -U postgres -d wpg -c "CREATE USER viadbuser WITH PASSWORD 'w0wAdm1n8'"
/usr/local/pgsql/bin/psql -U postgres -d wpg -c "GRANT CONNECT ON DATABASE wpg TO viadbuser WITH GRANT OPTION"
/usr/local/pgsql/bin/psql -U postgres -d wpg -c "GRANT USAGE, CREATE ON SCHEMA public TO viadbuser"

#---- now changed pg_restore to psql to restore non encoded schema backup file
#import database schema in postgresql db
/usr/local/pgsql/bin/psql -U postgres -d wpg < wpg_schema.sql


#set other permissions
/usr/local/pgsql/bin/psql -U postgres -d wpg -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public To viadbuser"
/usr/local/pgsql/bin/psql -U postgres -d wpg -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public To viadbuser"
/usr/local/pgsql/bin/psql -U postgres -d wpg -c "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public To viadbuser"
/usr/local/pgsql/bin/psql -U postgres -d wpg -c "GRANT ALL PRIVILEGES ON ALL PROCEDURES IN SCHEMA public To viadbuser"
/usr/local/pgsql/bin/psql -U postgres -d wpg -c "GRANT ALL PRIVILEGES ON ALL ROUTINES IN SCHEMA public To viadbuser"
/usr/local/pgsql/bin/psql -U postgres -d wpg -c "GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA public TO viadbuser"
/usr/local/pgsql/bin/psql -U postgres -d wpg -a -f owner_change_query.sql


#copy default database
/usr/bin/sudo cp -r default_db_backup/go2/wpg_pgsql_backup.sql /home/Collab8/config
/usr/bin/sudo chown -R $USER:$USER /home/Collab8/config/wpg_pgsql_backup.sql
/usr/bin/sudo chmod -R 777 /home/Collab8/config/wpg_pgsql_backup.sql


echo "database schema imported successfully"

/usr/bin/sudo cp -r postgres.service /lib/systemd/system/
/usr/bin/sudo ln -sf /lib/systemd/system/postgres.service /etc/systemd/system/multi-user.target.wants/postgres.service

#restart apache2
/usr/bin/sudo systemctl stop apache2.service
/usr/bin/sudo systemctl start apache2.service


curl --insecure http://localhost/migration/start

#stop mysql
/usr/bin/sudo systemctl stop mysql.service
/usr/bin/sudo systemctl disable mysql
