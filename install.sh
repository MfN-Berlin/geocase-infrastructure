#!/bin/bash

source install.cfg

echo "Do you wish to remove an existing GeoCASe database container before installation?"
select yn in "Yes" "No" "Cancel Installation"; do
    case $yn in
        Yes ) docker rm -f geocase_database; break;;
        No ) break;;
		"Cancel Installation" ) exit;;
    esac
done
echo 
echo 

echo "Starting GeoCASe database ..."
mkdir  -p $(pwd)/geocase_data
chmod -R 777 $(pwd)/geocase_data
docker run -d --restart always --name geocase_database -p $DOCKER_DATABASE_PORT:3306  --env "MYSQL_USER=$MYSQL_USER" --env "MYSQL_PASSWORD=$MYSQL_PASSWORD" --env "MYSQL_DATABASE=$MYSQL_DATABASE" --env "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" mariadb:latest
echo Waiting 30 seconds for the database server ...
sleep 30
echo
echo

echo "Do you wish to remove an existing BHIT container before installation?"
select yn in "Yes" "No" "Cancel Installation"; do
    case $yn in
        Yes ) docker rm -f geocase_bhit; break;;
        No ) break;;
		"Cancel Installation" ) exit;;
    esac
done
echo 
echo 

echo "Do you wish to remove an existing BHIT image before installation?"
select yn in "Yes" "No" "Cancel Installation"; do
    case $yn in
        Yes ) docker rmi geocase_bhit; break;;
        No ) break;;
		"Cancel Installation" ) exit;;
    esac
done
echo 
echo 

echo "Do you wish to build a new BHIT image?"
select yn in "Yes" "No" "Cancel Installation"; do
    case $yn in
        Yes ) docker build ./bhit/ -t geocase_bhit; break;;
        No ) break;;
		"Cancel Installation" ) exit;;
    esac
done
echo 
echo 

echo "Starting BHIT ..."
docker run -d --name geocase_bhit_tmp geocase_bhit
sleep 15s
docker cp geocase_bhit_tmp:/tmp/bhit/schemaOnly.sql bhit/schemaOnly.sql
docker cp bhit/schemaOnly.sql geocase_database:/tmp/schemaOnly.sql
rm -f bhit/schemaOnly.sql
docker rm -f geocase_bhit_tmp
docker exec geocase_database sh -c "cat /tmp/schemaOnly.sql | mysql -uroot -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE"
docker run -d --restart always --name geocase_bhit -p $DOCKER_BHIT_PORT:8080 --link geocase_database:geocase_database -v $(pwd)/bhit_data:/var/bhit/data geocase_bhit
echo
echo 

echo "Do you wish to remove an existing GeoCASe Portal container before installation?"
select yn in "Yes" "No" "Cancel Installation"; do
    case $yn in
        Yes ) docker rm -f geocase_portal; break;;
        No ) break;;
		"Cancel Installation" ) exit;;
    esac
done
echo 
echo 

echo "Do you wish to remove an existing GeoCASe Drupal 7 image before installation?"
select yn in "Yes" "No" "Cancel Installation"; do
    case $yn in
        Yes ) docker rmi geocase_drupal; break;;
        No ) break;;
		"Cancel Installation" ) exit;;
    esac
done
echo 
echo 

echo "Do you wish to build a new GeoCASe Drupal 7 image?"
select yn in "Yes" "No" "Cancel Installation"; do
    case $yn in
        Yes ) docker build ./geocase_portal/ -t geocase_drupal; break;;
        No ) break;;
		"Cancel Installation" ) exit;;
    esac
done
echo 
echo 

echo "Initiating Drupal 7 for GeoCASe Portal ..."
docker run -d --name geocase_portal_tmp geocase_drupal
docker cp geocase_portal_tmp:/var/www/html/sites/default $(pwd)/geocase_portal_sites/
docker rm -f geocase_portal_tmp
docker run -d --restart always  --name geocase_portal -p $DOCKER_GEOCASE_PORTAL_PORT:80 --link geocase_database:geocase_database -v $(pwd)/geocase_portal_sites:/var/www/html/sites geocase_drupal
docker exec geocase_portal chown -R www-data:www-data /var/www/html/sites
#docker exec geocase_portal sh -c "apt-get update && apt-get -y install unzip mysql-client && apt-get clean && rm -rf /var/lib/apt/lists/*"
#echo
#
#echo "Installing drush command ..."
#docker exec geocase_portal sh -c "cd /var/www/ && curl -sS https://getcomposer.org/installer | php"
#docker exec geocase_portal sh -c "ln -s /usr/local/bin/composer /usr/bin/composer"
#docker exec geocase_portal sh -c "curl -sL https://github.com/drush-ops/drush/archive/8.3.0.zip > /var/www/drush_8_3_0.zip"
#docker exec -it geocase_portal sh -c "cd /var/www/ && unzip -q drush_8_3_0.zip"
#docker exec -it geocase_portal sh -c "mv /var/www/drush-8.3.0 /usr/local/src/drush && rm -R /var/www/drush_8_3_0.zip"
#docker exec -it geocase_portal sh -c "cd /usr/local/src/drush/ && php /var/www/composer.phar install"
#docker exec -it geocase_portal sh -c "ln -s /usr/local/src/drush/drush /usr/bin/drush"
#echo
#
#echo "Testing drush ..."
#docker exec geocase_portal drush --version
echo
echo

echo "Installing GeoCASe's database structures ..."
docker cp geocase_portal/geocasePortal.sql geocase_database:/tmp/geocasePortal.sql
docker cp geocase_portal/geocase_bhit.sql geocase_database:/tmp/geocase_bhit.sql
docker exec geocase_database sh -c "cat /tmp/geocasePortal.sql | mysql -uroot -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE"
docker exec geocase_database sh -c "cat /tmp/geocase_bhit.sql | mysql -uroot -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE"
echo
echo
echo "Installing GeoCASe Portal ..."
sleep 10s
docker exec -it geocase_portal drush site-install --db-url=mysql://$MYSQL_USER:$MYSQL_PASSWORD@geocase_database:3306/geocase_portal
echo
echo "If the installation was successful, please note the admin password from the lines above."
read -p "Pressing any key to continue..."

echo "\$databases['bhit'] = array ( 'default' => array ('database' => '$MYSQL_DATABASE', 'username' => '$MYSQL_USER', 'password' => '$MYSQL_PASSWORD', 'host' => 'geocase_database', 'port' => '', 'driver' => 'mysql', 'prefix' => '',));" >> geocase_portal_sites/default/settings.php

docker exec -it geocase_portal drush dl -y views views_database_connector webform
docker exec -it geocase_portal drush en -y views views_ui views_database_connector webform
docker exec -it geocase_portal drush cc all

echo
echo 

echo Done!
echo BHIT at http://localhost:$DOCKER_BHIT_PORT/bhit/
echo GeoCASe Portal at http://localhost:$DOCKER_GEOCASE_PORTAL_PORT/
echo 
echo Please manually import the BHIT-GeoCASe Drupal View at http://localhost:$DOCKER_GEOCASE_PORTAL_PORT/localhost/admin/structure/views/import
