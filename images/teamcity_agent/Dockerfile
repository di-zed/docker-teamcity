ARG TEAMCITY_VERSION=0.0

FROM jetbrains/teamcity-agent:${TEAMCITY_VERSION}-linux-sudo

USER root
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
RUN apt-get update && apt-get install -y nodejs php-cli rsync
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
USER buildagent