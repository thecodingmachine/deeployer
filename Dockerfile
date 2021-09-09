FROM thecodingmachine/k8s_gitlabci:2.0.5

ENV SILENT_WARNINGS=1
RUN mkdir /var/app


RUN curl -fSL -o "/usr/local/bin/tk" "https://github.com/grafana/tanka/releases/download/v0.9.0/tk-linux-amd64" && chmod a+x "/usr/local/bin/tk"
RUN mkdir jsonnetdownload && cd jsonnetdownload && curl -fSL -o jsonnet.tar.gz https://github.com/google/jsonnet/releases/download/v0.15.0/jsonnet-bin-v0.15.0-linux.tar.gz && \
    tar xzf jsonnet.tar.gz && \
    mv jsonnet /usr/local/bin && \
    mv jsonnetfmt /usr/local/bin && \
    cd .. && \
    rm -rf jsonnetdownload

RUN curl -fSL -o "/usr/local/bin/jb" "https://github.com/jsonnet-bundler/jsonnet-bundler/releases/download/v0.3.1/jb-linux-amd64" && chmod a+x "/usr/local/bin/jb"

# install NodeJS and jq
RUN apt-get update &&\
    apt-get install -y --no-install-recommends gnupg &&\
    curl -sL https://deb.nodesource.com/setup_12.x | bash - &&\
    apt-get update &&\
    apt-get install -y --no-install-recommends nodejs jq docker-compose curl php-dom php-mbstring php-zip php-curl unzip

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" &&\
    php composer-setup.php --install-dir=bin --filename=composer &&\
    php -r "unlink('composer-setup.php');"


# install AJV for schema validation
RUN npm install -g ajv-cli@^5
RUN npm install -g ajv-formats@^2.1.1

COPY . /deeployer

RUN cd /deeployer && jb install

RUN cd /deeployer && composer install

RUN ln -s /deeployer/scripts/deeployer-k8s /usr/local/bin/deeployer-k8s
RUN ln -s /deeployer/scripts/deeployer-compose.php /usr/local/bin/deeployer-compose

WORKDIR /var/app

