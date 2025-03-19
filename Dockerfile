FROM redgate/flyway:11.4.0-alpine 

COPY ./scripts /flyway/sql

ARG VERSION
ENV VERSION=${VERSION:-develop}
RUN echo ${VERSION} > version
