#!/bin/bash

echo "Installing GeoCASe Portal ..."
sleep 10s
docker exec -it geocase_portal sh -c "echo \"ini_set('memory_limit', '512M');\" >> /var/www/html/drush/drushrc.php"
docker restart geocase_portal geocase_database
docker exec -it geocase_portal drush site-install --db-url=mysql://$MYSQL_USER:$MYSQL_PASSWORD@geocase_database:$DOCKER_DATABASE_PORT/geocase_portal
echo
echo "If the installation was successful, please note the admin password from the lines above."
read -p "Press any key to continue..."

echo "\$databases['default'] = array ( 'default' => array ('database' => '$MYSQL_GEOCASE_DATABASE', 'username' => '$MYSQL_USER', 'password' => '$MYSQL_PASSWORD', 'host' => 'geocase_database', 'port' => '', 'driver' => 'mysql', 'prefix' => '',));" >> geocase_portal_sites/default/settings.php
echo "\$databases['bhit'] = array ( 'default' => array ('database' => '$MYSQL_BHIT_DATABASE', 'username' => '$MYSQL_USER', 'password' => '$MYSQL_PASSWORD', 'host' => 'geocase_database', 'port' => '', 'driver' => 'mysql', 'prefix' => '',));" >> geocase_portal_sites/default/settings.php

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

