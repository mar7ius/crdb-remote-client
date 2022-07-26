FROM maven:3.8-adoptopenjdk-15 as builder
WORKDIR /app
COPY ./pom.xml ./pom.xml
RUN mvn dependency:go-offline -B
COPY ./src ./src
RUN mvn package && cp target/*.jar application.jar
RUN java -Djarmode=layertools -jar application.jar extract

FROM mar7ius/cockroach_macos_arm:v22.1.3_arm64 as cockroach

FROM adoptopenjdk:15-jdk
COPY --from=builder /app/dependencies/ ./
COPY --from=builder /app/snapshot-dependencies/ ./
COPY --from=builder /app/spring-boot-loader/ ./
COPY --from=builder /app/application/ ./
COPY --from=cockroach /cockroach/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
