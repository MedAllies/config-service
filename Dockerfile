FROM azul/zulu-openjdk-alpine:8u282-jre

# Run system update
RUN apk update
RUN apk upgrade --ignore zulu8-*
RUN apk add --no-cache --upgrade bash

# Added for DNS testing - remove after success
RUN apk add bind-tools
RUN apk add busybox-extras
# Added for DNS testing - remove after success

RUN apk add --no-cache curl && \
    rm -rf /var/cache/apk/*

# When build images, name with this tag
LABEL tag=config-service

# Build arguments
ARG BUILD_VERSION=8.1.0-SNAPSHOT

# Create and use local user and group
RUN addgroup -S direct && adduser -S -D direct -G direct

# Set application location
RUN mkdir -p /opt/app
RUN chown direct:direct /opt/app
ENV PROJECT_HOME /opt/app

ARG DEPLOY_PLATFORM=docker
ENV DEPLOY_PLATFORM ${DEPLOY_PLATFORM}

# Set microservice
ENV CLOUD_CONFIG=true
ENV SERVICE_PORT=8082
ENV SERVICE_USERNAME=admin
ENV SERVICE_PASSWORD=direct

# Set default HISP domain and postmaster email
ENV DEFAULT_DOMAIN=my.hisp.local
ENV DEFAULT_POSTMASTER=postmaster@my.hisp.local

# Set MYSQL env variables
ENV MYSQL_HOST=mysql
ENV MYSQL_PORT=3306
ENV MYSQL_DATABASE=nhind
ENV MYSQL_USER=nhind
ENV MYSQL_PASSWORD=nhind

# Use local user and group
USER direct:direct

# Copy application artifact
COPY src/main/resources/bootstrap-$DEPLOY_PLATFORM.properties $PROJECT_HOME/bootstrap.properties
COPY src/main/resources/application-$DEPLOY_PLATFORM.properties $PROJECT_HOME/application.properties
COPY target/config-service-$BUILD_VERSION.jar $PROJECT_HOME/config-service.jar

#chmod +x configServiceDomain.sh on a local before copy
COPY configServiceDomain.sh $PROJECT_HOME/configServiceDomain.sh

# Switching to the application location
WORKDIR $PROJECT_HOME

# Run application
CMD ./configServiceDomain.sh
