# GeoCASe Infrastructure

This code installs the basic infrastructure that is used for the Geoscientific Collection Access Service (GeoCASe).
It consists of Docker containers of the following software components
* the Berlin Harvesting and Indexing Toolkit (BHIT; https://wiki.bgbm.org/bhit/)
* the database management system MariaDB (https://mariadb.org)
* the content management system Drupal 7 (https://www.drupal.org/drupal-7.0)


In order to roll out the components please copy or rename the file `install.cfg.example` to `install.cfg` and edit configuration in the file.
The deployment is designed for Linux OS  (tested with Ubuntu 16.04 and 18.04)

* after cloning this Git repository make `install.sh` executable by
 `chmod +x install.sh`
* then start the installation with
 `./install.sh`