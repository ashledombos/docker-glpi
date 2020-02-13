#!/bin/bash
set -e

# Reconfigure php.ini
# set PHP.ini settings for GLPI
( \
echo "post_max_size=${PHP_POST_MAX_SIZE}"; \
echo "upload_max_filesize=${PHP_UPLOAD_MAX_FILESIZE}"; \
echo "date.timezone=${PHP_TIMEZONE}"; \
echo "memory_limit=${PHP_MEMORY_LIMIT}"; \
echo "file_uploads = on ;"
echo "max_execution_time=${PHP_MAX_EXECUTION_TIME}"; \
echo "register_globals = off"; \
echo "magic_quotes_sybase = off"; \
echo "session.auto_start = off"; \
echo "session.use_trans_sid = 0"; \
) > /usr/local/etc/php/conf.d/glpi.ini

# Separate the core of GLPI and data
# Copy GLPI core to shared volume.
echo >&2 "Setting GLPI core in $PWD/core/"
rm -Rf /var/www/html/core/*
tar cf - --one-file-system -C /usr/src/glpi . | tar xf - -C core
echo >&2 "Complete! GLPI has been successfully copied to $PWD/core/"

# IMG and config will be modified so let's move it to data volume
#echo >&2 "Move IMG and config in $PWD/data/ if needed"
if [ ! -d data/files ]; then
  mv core/files data/
else
  rm -Rf core/files
fi
if [ ! -d data/config ]; then
  mv core/config data/
else
  rm -Rf core/config
fi
if [ ! -d data/plugins ]; then
  mv core/plugins data/
else
  rm -Rf core/plugins
fi

#manage install folder
mv core/install core/install_dir

# For better performance, we include the content of htaccess.txt in apache conf
echo >&2 "Apache uses $PWD/data/htaccess.txt for global configuration"
if [ ! -e data/.htaccess ]; then
  cp /usr/src/glpi/.htaccess data/htaccess.txt
fi

# For better performance, we include the content of htdir.txt in apache conf
echo >&2 "Apache uses $PWD/data/htdir.txt for location and directory rules"
if [ ! -e /var/www/html/data/htdir.txt ]; then
  echo "#Put your Apache Directory or Location rules here" > /var/www/html/data/htdir.txt;
fi

echo >&2 "change rights"
chown -R www-data:www-data data/files data/config data/plugins

# As core directory is the webroot directory, we link all subdirectories from data volume
echo >&2 "create all symlinks"
ln -s $PWD/data/files core/
ln -s $PWD/data/config core/

# Copy plugins directory because of symbolic links issue
cp -Rf /var/www/html/data/plugins /var/www/html/core/plugins
#Add cronjob

# set PHP.ini settings for GLPI
#( \
#echo '*/2 * * * * apache PHP GLPI/front/cron.php'; \
#) > /etc/crontabs/root

#/usr/sbin/crond -f

exec "$@"

