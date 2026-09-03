# Java Hello World - DevOps homework
# Build stage: compile the source with a full JDK
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /build
COPY src/HelloServer.java .
RUN javac HelloServer.java

# Run stage: only the JRE + the compiled class is shipped
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /build/HelloServer.class .

EXPOSE 8080
CMD ["java", "HelloServer"]
