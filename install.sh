#!/bin/bash

source install.cfg

echo "Do you wish to remove an existing GeoCASe database container (if installed) before installation?"
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
docker run -d --restart always --name geocase_database -p $DOCKER_DATABASE_PORT:3306  --env "MYSQL_USER=$MYSQL_USER" --env "MYSQL_PASSWORD=$MYSQL_PASSWORD" --env "MYSQL_DATABASE=$MYSQL_BHIT_DATABASE" --env "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" mariadb:latest
echo Waiting 30 seconds for the database server ...
sleep 30
echo
echo

echo "Do you wish to remove an existing BHIT container (if installed) before installation?"
select yn in "Yes" "No" "Cancel Installation"; do
    case $yn in
        Yes ) docker rm -f geocase_bhit; break;;
        No ) break;;
		"Cancel Installation" ) exit;;
    esac
done
echo 
echo 

echo "Do you wish to remove an existing BHIT image (if installed) before installation?"
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
echo Waiting 15 seconds for the BHIT server ...
sleep 15s
docker cp geocase_bhit_tmp:/tmp/bhit/schemaOnly.sql bhit/schemaOnly.sql
docker cp bhit/schemaOnly.sql geocase_database:/tmp/schemaOnly.sql
rm -f bhit/schemaOnly.sql
docker rm -f geocase_bhit_tmp
docker exec geocase_database sh -c "cat /tmp/schemaOnly.sql | mysql -uroot -p$MYSQL_ROOT_PASSWORD $MYSQL_BHIT_DATABASE"
docker run -d --restart always --name geocase_bhit -p $DOCKER_BHIT_PORT:8080 --link geocase_database:geocase_database -v $(pwd)/bhit_data:/var/bhit/data geocase_bhit
echo
echo 

echo "Do you wish to remove an existing GeoCASe Portal container (if installed) before installation?"
select yn in "Yes" "No" "Cancel Installation"; do
    case $yn in
        Yes ) docker rm -f geocase_portal; break;;
        No ) break;;
		"Cancel Installation" ) exit;;
    esac
done
echo 
echo 

echo "Do you wish to remove an existing GeoCASe Drupal 7 image (if installed) before installation?"
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
sleep 3s
docker run -d --restart always  --name geocase_portal -p $DOCKER_GEOCASE_PORTAL_PORT:80 --link geocase_database:geocase_database -v $(pwd)/geocase_portal_sites:/var/www/html/sites geocase_drupal
docker exec geocase_portal chown -R www-data:www-data /var/www/html/sites
echo
echo

echo "Installing GeoCASe's database structures ..."
echo "Do you agree to re-create an existing GeoCASe database?"
select yn in "Yes" "No" "Cancel Installation"; do
    case $yn in
        Yes ) 
		docker cp geocase_portal/geocasePortal.sql geocase_database:/tmp/geocasePortal.sql;
		docker cp geocase_portal/geocase_bhit.sql geocase_database:/tmp/geocase_bhit.sql;
		docker exec geocase_database sh -c "cat /tmp/geocasePortal.sql | mysql -uroot -p$MYSQL_ROOT_PASSWORD";
		docker exec geocase_database sh -c "cat /tmp/geocase_bhit.sql | mysql -uroot -p$MYSQL_ROOT_PASSWORD $MYSQL_BHIT_DATABASE";
		break;;
        No ) break;;
        "Cancel Installation" ) exit;;
    esac
done
echo 
echo

source initial_portal_setup.sh
