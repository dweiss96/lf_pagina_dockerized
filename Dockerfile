FROM maven:3.9.5-sapmachine-21 as inspector_builder
WORKDIR /src
COPY InspectorWS /src
RUN mvn package -DcloneUi
RUN ls -hals

# FROM maven:3.9.5-sapmachine-21 as langtool_builder
# RUN git clone --branch v6.2 --depth 1 https://github.com/languagetool-org/languagetool.git /src
# WORKDIR /src
# RUN mvn package -DcloneUi
# RUN ls -hals


FROM tomcat:10.1.15-jdk21-temurin-jammy
COPY --from=inspector_builder /src/target/InspectorWS-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/InspectorWS.war
# configure dependency sources
RUN apt update
RUN apt -y install software-properties-common
RUN mkdir -p /etc/apt/keyrings
RUN apt update
RUN add-apt-repository ppa:savoury1/ffmpeg4
RUN add-apt-repository ppa:savoury1/chromium
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt update

# install dependencies
# RUN echo ${BUILDARCH}
# RUN echo ${TARGETARCH}
# RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_${TARGETARCH}.deb
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt -y install ./google-chrome-stable_current_amd64.deb
RUN apt -y install ca-certificates curl gnupg python3 python3-pip
RUN apt -y install chromium-browser
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
RUN apt -y install nodejs

# Spelling
RUN mkdir -p /opt/scripts/languagetool/data
RUN mkdir -p /opt/scripts/languagetool/content
COPY deps/LangToolHTTPServer /opt/LangToolHTTPServer
# Images
RUN mkdir -p /opt/scripts/images
RUN mkdir -p /opt/scripts/images/data
RUN pip install Pillow requests bs4 --no-cache-dir
COPY Scripts/Images.py /opt/scripts/images/Images.py
# rest of scripts
COPY Scripts /opt/scripts
