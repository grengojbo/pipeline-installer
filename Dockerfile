FROM banzaicloud/pipeline-installer

RUN set -xe && \
    apk add --update --no-cache postgresql-client \
    && rm -rf /var/cache/apk/*