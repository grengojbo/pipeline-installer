FROM banzaicloud/pipeline-installer

RUN set -xe && \
    apk add --update --no-cache postgresql-client curl ca-certificates bash make \
    && rm -rf /var/cache/apk/*

ARG KUBERNETES_VERSION

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kubectl && \
  chmod +x ./kubectl && \
  mv ./kubectl /usr/bin/kubectl

ARG HELM_VERSION

RUN curl -L https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz |tar xvz && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-amd64


# COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
# COPY --from=builder /app /app

ARG VCS_REF
ARG BUILD_DATE
# Metadata
LABEL autor="Oleg Dolya <oleg.dolya@gmail.com>" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.name="pipeline-installer" \
      org.label-schema.url="https://https://hub.docker.com/r/grengojbo/pipeline-installer/" \
      org.label-schema.vcs-url="https://github.com/grengojbo/pipeline-installer/" \
      org.label-schema.build-date=$BUILD_DATE

# USER nobody:nobody
