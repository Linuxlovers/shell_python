FROM 10.10.70.65/base/tomcat:jdk8tomcat8
RUN mkdir -p /tmp/war
LABEL version="1.0" description="workmanager"
COPY newWorkmanage.war /tmp/war/
COPY entry-point.sh /usr/local/bin/
RUN chmod 750 /usr/local/bin/entry-point.sh
CMD ["/usr/local/bin/entry-point.sh"]
