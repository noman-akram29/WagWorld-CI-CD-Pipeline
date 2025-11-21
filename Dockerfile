# Dockerfile
FROM openjdk:17.0.2

WORKDIR /usr/src/myapp


COPY mvnw .
COPY .mvn .mvn/
COPY pom.xml .


COPY src ./src


RUN chmod +x ./mvnw && ./mvnw -B clean package -DskipTests

EXPOSE 8080


CMD ["./mvnw", "cargo:run", "-Ptomcat90"]