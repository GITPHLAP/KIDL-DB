FROM redgate/flyway:11.13.1-alpine 

COPY ./scripts /flyway/sql

ARG VERSION
ENV VERSION=${VERSION:-develop}
RUN echo ${VERSION} > version
