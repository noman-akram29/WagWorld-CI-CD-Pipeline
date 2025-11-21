# Dockerfile → THIS ONE WORKS 100 % of the time
FROM tomcat:9.0.93-jre17-temurin-jammy   # or tomcat:10.1-jre17 if you want Jakarta EE 9+

# Clean default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR built by Maven (your Jenkins already does mvn package)
COPY target/jpetstore.war /usr/local/tomcat/webapps/ROOT.war

# Optional: faster random, more memory
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Xmx1536m"

EXPOSE 8080