FROM redgate/flyway:13.6.0-alpine 

COPY ./scripts /flyway/sql

ARG VERSION
ENV VERSION=${VERSION:-develop}
RUN echo ${VERSION} > version
