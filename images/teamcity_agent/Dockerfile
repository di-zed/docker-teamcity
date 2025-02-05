ARG TEAMCITY_VERSION=0.0

FROM jetbrains/teamcity-agent:${TEAMCITY_VERSION}-linux-sudo

USER root
RUN apt-get update && apt-get install -y rsync