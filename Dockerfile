# Dockerfile → THE ONLY ONE THAT WORKS
FROM tomcat:9.0.93-jre17-temurin-jammy

# Clean default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR that Jenkins already built
COPY target/jpetstore.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080