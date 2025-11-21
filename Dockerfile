
FROM tomcat:9.0.93-jre17-temurin-jammy


RUN rm -rf /usr/local/tomcat/webapps/*


COPY target/jpetstore.war /usr/local/tomcat/webapps/ROOT.war


ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Xms512m -Xmx1536m"

EXPOSE 8080

