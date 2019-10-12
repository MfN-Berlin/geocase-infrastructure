FROM tomcat:7.0-jre8
MAINTAINER Falko Gloeckler <falko.gloeckler@mfn-berlin.de>

# Install some dependencies
RUN apt-get update
RUN apt-get -y install zip curl	
# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd tomcat7
RUN sed -i -e's@<\/tomcat-users>@<role rolename="manager"\/>\n<user username="root" password="yourTomcatManagerPassword" roles="manager-gui"\/>\n<\/tomcat-users>@g' /usr/local/tomcat/conf/tomcat-users.xml

# Download BHIT
RUN mkdir -p /tmp/bhit \
	&& cd /tmp/bhit \
	&& curl -sL http://ww3.bgbm.org/bhit/bhit_latest.war > bhit.war \
	&& curl -sL http://ww2.biocase.org/svn/binhum/trunk/BinHum/Harvester/schemaOnly.sql > schemaOnly.sql

	
RUN mkdir -p /var/bhit/data

COPY application.properties /tmp/bhit/WEB-INF/classes/application.properties

RUN cd /tmp/bhit \
	&& zip -r bhit.war ./WEB-INF/classes/application.properties \
	&& chown tomcat7:tomcat7 bhit.war \
	&& mv bhit.war $CATALINA_HOME/webapps/
	
VOLUME /var/bhit/data

EXPOSE 8080
