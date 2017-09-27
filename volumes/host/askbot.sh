#!/usr/bin/env bash
set -e

##################OPTIONAL INPUT PARAMATERS VIA ENVIRONMENT
# ASKBOT_ROOT
# ASKBOT_DB_HOST
# ASKBOT_DB_PORT
# ASKBOT_DB_TYPE
# ASKBOT_DB_USERNAME
# ASKBOT_DB_PASSWORD

apt-get --assume-yes update
# apt-get --assume-yes install python-mysqldb
# apt-get --assume-yes install binutils libproj-dev gdal-bin
# apt-get --assume-yes install python-pip python-dev libpq-dev postgresql postgresql-contrib
# apt-get --assume-yes install postgresql postgresql-contrib
apt-get --assume-yes install libpq-dev
apt-get --assume-yes install python-psycopg2
# pip install psycopg2

/host/wait-for-it.sh askbot-postgres-db:5432;

ROOT='askbot/';
DB_HOST='db'
DB_PORT='5432'
DB_TYPE='postgresql_psycopg2'
DB_USERNAME='postgres';
DB_PASSWORD='password';

function settingsFromEnvironment() {
    SETTING=$ASKBOT_ROOT
    if [ -n $SETTING ]; then
        ROOT=$SETTING
    fi
    SETTING=$ASKBOT_DB_HOST
    if [ -n $SETTING ]; then
        DB_HOST=$SETTING
    fi
    SETTING=$ASKBOT_DB_PORT
    if [ -n $SETTING ]; then
        DB_PORT=$SETTING
    fi
    SETTING=$ASKBOT_DB_TYPE
    if [ -n $SETTING ]; then
        DB_TYPE=$SETTING
    fi
    SETTING=$ASKBOT_DB_USERNAME
    if [ -n $SETTING ]; then
        DB_USERNAME=$SETTING
    fi
    SETTING=$ASKBOT_DB_PASSWORD
    if [ -n $SETTING ]; then
        DB_PASSWORD=$SETTING
    fi
}

function changeSettings() {
    settingsFromEnvironment;
    # DEBUG
    SUB_OLD="DEBUG = False"
    SUB_NEW="DEBUG = True"
    sed -i "s|$SUB_OLD|$SUB_NEW|g" /app/settings.py
    echo "Changed From: $SUB_OLD  |||||| To: $SUB_NEW"
    # uWSGI IP
    SUB_OLD="0.0.0.0"
    SUB_NEW="askbot"
    sed -i "s|$SUB_OLD|$SUB_NEW|g" /app/deploy/uwsgi.ini
    echo "Changed From: $SUB_OLD  |||||| To: $SUB_NEW"
    # uWSGI STATIC MAP
    SUB_OLD="0.0.0.0"
    SUB_NEW="askbot"
    sed -i "s|$SUB_OLD|$SUB_NEW|g" /app/deploy/uwsgi.ini
    echo "Changed From: $SUB_OLD  |||||| To: $SUB_NEW"
    # uWSGI PROTO PORT
    SUB_OLD="bin/uwsgi "
    SUB_NEW="bin/uwsgi --socket :8888 "
    sed -i "s|$SUB_OLD|$SUB_NEW|g" /app/deploy/run.sh 
    echo "Changed From: $SUB_OLD  |||||| To: $SUB_NEW"
    # uWSGI MEDIA MAP
    SUB_OLD="/m="
    SUB_NEW="/askbot/m="
    sed -i "s|$SUB_OLD|$SUB_NEW|g" /app/deploy/uwsgi.ini
    echo "Changed From: $SUB_OLD  |||||| To: $SUB_NEW"
    # ROOT
    SUB_OLD="ASKBOT_URL = ''"
    SUB_NEW="ASKBOT_URL = '$ROOT'"
    sed -i "s|$SUB_OLD|$SUB_NEW|g" /app/settings.py
    echo "Changed From: $SUB_OLD  |||||| To: $SUB_NEW"
    # STATIC
    SUB_OLD="STATIC_URL = '/m/'"
    SUB_NEW="STATIC_URL = '/askbot/m/'"
    sed -i "s|$SUB_OLD|$SUB_NEW|g" /app/settings.py
    echo "Changed From: $SUB_OLD  |||||| To: $SUB_NEW"
    # MEDIA
    SUB_OLD="MEDIA_URL = '/upfiles/'"
    SUB_NEW="MEDIA_URL = '/askbot/upfiles/'"
    sed -i "s|$SUB_OLD|$SUB_NEW|g" /app/settings.py
    echo "Changed From: $SUB_OLD  |||||| To: $SUB_NEW"
    # NAME
    SUB_OLD="'NAME': '/data/askbot.db',"
    SUB_NEW="'NAME': 'askbot',"
    sed -i "s|$SUB_OLD|$SUB_NEW|g" /app/settings.py
    echo "Changed From: $SUB_OLD  |||||| To: $SUB_NEW"
    # DB_HOST
    SUB_OLD="'HOST': ''"
    SUB_NEW="'HOST': '$DB_HOST'"
    sed -i "s|$SUB_OLD|$SUB_NEW|g" /app/settings.py
    echo "Changed From: $SUB_OLD  |||||| To: $SUB_NEW"
    # DB_PORT
    SUB_OLD="'PORT': ''"
    SUB_NEW="'PORT': '$DB_PORT'"
    sed -i "s|$SUB_OLD|$SUB_NEW|g" /app/settings.py
    echo "Changed From: $SUB_OLD  |||||| To: $SUB_NEW"
    # DB_TYPE
    SUB_OLD="'django.db.backends.sqlite3'"
    SUB_NEW="'django.db.backends.$DB_TYPE'"
    sed -i "s|$SUB_OLD|$SUB_NEW|g" /app/settings.py
    echo "Changed From: $SUB_OLD  |||||| To: $SUB_NEW"
    # DB_USERNAME
    SUB_OLD="'USER': ''"
    SUB_NEW="'USER': '$DB_USERNAME'"
    sed -i "s|$SUB_OLD|$SUB_NEW|g" /app/settings.py
    echo "Changed From: $SUB_OLD  |||||| To: $SUB_NEW"
    # DB_PASSWORD
    SUB_OLD="'PASSWORD': ''"
    SUB_NEW="'PASSWORD': '$DB_PASSWORD'"
    sed -i "s|$SUB_OLD|$SUB_NEW|g" /app/settings.py
    echo "Changed From: $SUB_OLD  |||||| To: $SUB_NEW"
    # # DB SYNC
    # SUB_OLD="python /app/manage.py migrate --noinput"
    # SUB_NEW="python manage.py makemigrations askbot\npython /app/manage.py migrate --noinput"
    # sed -i "s|$SUB_OLD|$SUB_NEW|g" /app/deploy/run.sh
    # echo "Changed From: $SUB_OLD  |||||| To: $SUB_NEW"
}

#### DO NO MATTER WHAT
changeSettings;

#### NO CMD(s)
if [ "$#" -eq 0 ]; then
    echo "Running /app/deploy/run.sh"
    /app/deploy/run.sh
fi

#### CMD(s)
echo "Running '$@'"
exec "$@"
