FROM thecodingmachine/k8s_gitlabci:2.0.3

ENV SILENT_WARNINGS=1
RUN mkdir /var/app


RUN curl -fSL -o "/usr/local/bin/tk" "https://github.com/grafana/tanka/releases/download/v0.9.0/tk-linux-amd64" && chmod a+x "/usr/local/bin/tk"
RUN curl -fSL -o "/usr/local/bin/jb" "https://github.com/jsonnet-bundler/jsonnet-bundler/releases/download/v0.3.1/jb-linux-amd64" && chmod a+x "/usr/local/bin/jb"


COPY . /deeployer

RUN cd /deeployer && jb install

RUN ln -s /deeployer/scripts/deeployer-k8s /usr/local/bin/deeployer-k8s

WORKDIR /var/app

#RUN cp /var/app/deeployer.libsonnet lib/deeployer/deeployer.libsonnet


#COPY Docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh


#ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

