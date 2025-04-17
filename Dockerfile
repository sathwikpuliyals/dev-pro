FROM amazoncorretto:17.0.8-alpine3.18
    
EXPOSE 8080
 
ENV APP_HOME /usr/src/app



WORKDIR $APP_HOME

CMD ["java", "-jar", "app.jar"]
