FROM redgate/flyway:10.20.1-alpine 

COPY ./scripts /flyway/sql

ARG VERSION
ENV VERSION=${VERSION:-develop}
RUN echo ${VERSION} > version
