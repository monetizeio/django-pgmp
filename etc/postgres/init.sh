#!/bin/bash

POSTGRES_VERSION=9.1

sudo cp -a /etc/postgresql/9.1/main/postgresql.conf .
sudo cp -a /etc/postgresql/9.1/main/pg_hba.conf .
sudo -u postgres pg_dropcluster --stop 9.1 main
sudo -u postgres pg_createcluster -E 'UTF-8' --lc-collate='en_US.UTF-8' --lc-ctype='en_US.UTF-8' --locale='en_US.UTF-8' 9.1 main
sudo cp -a ./postgresql.conf /etc/postgresql/9.1/main
sudo cp -a ./pg_hba.conf /etc/postgresql/9.1/main
sudo /etc/init.d/postgresql restart
sudo -u postgres psql postgres -c "CREATE EXTENSION IF NOT EXISTS pgmp;"
sudo -u postgres psql template1 -c "CREATE EXTENSION IF NOT EXISTS pgmp;"
sudo -u postgres psql -c "CREATE USER django WITH PASSWORD 'password';"
sudo -u postgres psql -c "ALTER ROLE django WITH CREATEDB"
sudo -u postgres psql -c "CREATE DATABASE django;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE django TO django;"
