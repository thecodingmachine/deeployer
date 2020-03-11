FROM thecodingmachine/k8s-gitlabci

RUN mkdir /var/app


RUN git clone https://github.com/grafana/tanka
RUN cd tanka
RUN make install
RUN go get -u github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb


RUN mkdir ~/tanka
RUN cd ~/tanka
RUN tk init

RUN mkdir ~/tanka/lib/deeployer

COPY lib/deeployer/config.libsonnet  ~/tanka/lib/deeployer/config.libsonnet

RUN cp /var/app/deeployer.libsonnet lib/deeployer/deeployer.libsonnet


COPY Docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh


ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]


