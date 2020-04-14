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
    apt-get install -y --no-install-recommends nodejs jq

# install AJV for schema validation
RUN npm install -g ajv-cli

COPY . /deeployer

RUN cd /deeployer && jb install

RUN ln -s /deeployer/scripts/deeployer-k8s /usr/local/bin/deeployer-k8s

WORKDIR /var/app

#RUN cp /var/app/deeployer.libsonnet lib/deeployer/deeployer.libsonnet


#COPY Docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh


#ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

