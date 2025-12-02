FROM eclipse-temurin:17-jdk

WORKDIR /app

COPY target/eventsProject-1.0.0.jar app.jar

EXPOSE 8089

ENTRYPOINT ["java", "-jar", "app.jar"]
