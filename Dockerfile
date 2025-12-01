FROM openjdk:17

WORKDIR /app

# Le JAR généré par "mvn clean package"
COPY target/eventsProject-1.0.0.jar app.jar

EXPOSE 8089

ENTRYPOINT ["java", "-jar", "app.jar"]
