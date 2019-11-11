FROM drupal:7
MAINTAINER Falko Gloeckler <falko.gloeckler@mfn-berlin.de>

# Install some dependencies
RUN apt-get update
RUN apt-get -y install unzip curl mysql-client	
# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN cd /var/www/ \
	&& curl -sS https://getcomposer.org/installer | php
RUN ln -s /usr/local/bin/composer /usr/bin/composer

RUN curl -sL https://github.com/drush-ops/drush/archive/8.3.0.zip > /var/www/drush_8_3_0.zip
RUN cd /var/www/ \
	&& unzip -q drush_8_3_0.zip \
	&& mv /var/www/drush-8.3.0 /usr/local/src/drush && rm -R /var/www/drush_8_3_0.zip \
	&& mkdir -p /var/www/html/drush \
	&& cp /usr/local/src/drush/examples/example.drushrc.php /var/www/html/drush/drushrc.php \ 
	&& echo "ini_set('memory_limit', '512M');" >> /var/www/html/drush/drushrc.php

RUN cd /usr/local/src/drush/ \
	&& php /var/www/composer.phar install
RUN ln -s /usr/local/src/drush/drush /usr/bin/drush

RUN echo "Testing drush ..." \
	&& drush --version
