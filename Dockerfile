FROM python:3-alpine3.13

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=${BUILD_DATE} \
          org.label-schema.name="s3-pit-restore" \
          org.label-schema.description="a point in time restore tool for Amazon S3." \
          org.label-schema.vcs-ref=${VCS_REF} \
          org.label-schema.vcs-url="https://github.com/angeloc/s3-pit-restore" \
          org.label-schema.vendor="newrelic" \
          org.label-schema.version=${VERSION} \
          org.label-schema.schema-version="v0.1"

RUN pip3 --no-cache-dir install s3-pit-restore awscli

ENTRYPOINT [ "s3-pit-restore" ]
CMD [ "-h" ]
