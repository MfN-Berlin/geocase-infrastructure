# GeoCASe Infrastructure

This code installs the basic infrastructure that is used for the Geoscientific Collection Access Service (GeoCASe).
It consists of Docker containers of the following software components
* the Berlin Harvesting and Indexing Toolkit (BHIT; https://wiki.bgbm.org/bhit/)
* the database management system MariaDB (https://mariadb.org)
* the content management system Drupal 7 (https://www.drupal.org/drupal-7.0)

# Requirements
* Linux operating system
* installed Docker engine (https://www.docker.com/)
* internet connection during installation procedure
* knowledge in the usage of Docker, Drupal 7 and BHIT
* knowledge about the idea of Biodiversity Standards and decentral data provision

# Installation
In order to roll out the components please copy or rename the file `install.cfg.example` to `install.cfg` and edit configuration in the file.
The deployment is designed for Linux OS  (tested with Ubuntu 16.04 and 18.04)

* after cloning this Git repository make _install.sh_ executable by
 `chmod +x install.sh`
* then start the installation with
 `./install.sh`
* follow the instructions of the installation script
* after a successfull installation the BHIT and a Drupal website should be available
  e.g. BHIT at http://localhost:8080/bhit/  and the Drupal website (GeoCASe Portal) at http://localhost/  (depending on your configuration)
* in order to connect BHIT and the Drupal website, you need to manually import the file `geocase_portal/geocase_bhit.views.export` in the Drupal Views module (e.g. http://localhost/admin/structure/views/import)
* this creates a Block (http://localhost/admin/structure/block) called _BHIT_ that must be activated by assigning a region in the template in order to display the block.

# Usage
In order to access data in the portal you need to register and harvest data sources in BHIT in order to aggregate the decentral data. Only after harvesting the Block will display data in the portal.
Please visit https://wiki.bgbm.org/bhit/ in order to learn how to use BHIT.

# Disclaimer
The code deploys the underlying GeoCASe infrastructure components and not a copy of http://geocase.eu! Thus, no content and/or design is shipped with this code.

__You use this code on your own risk__!! There is no guarantee for a state-of-the-art web security in these services. The authors of this code are not liable for any harm or damage caused through the usage of this code, these instructions or any external sources used.

It is highly recommended to deploy the infrastructure in a secured virtual environment e.g. on a local maschine, instead of a production server with other services.
