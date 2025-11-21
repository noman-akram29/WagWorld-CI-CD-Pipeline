FROM openjdk:17.0.2


COPY . /usr/src/myapp
WORKDIR /usr/src/myapp


RUN chmod +x mvnw


RUN ./mvnw clean package -DskipTests


CMD ["./mvnw", "cargo:run", "-Ptomcat90"]