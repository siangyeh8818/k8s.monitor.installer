#FROM golang:1.11
FROM alpine:3.5


COPY kubectl /usr/bin/kubectl
#COPY kustomize  /usr/bin/kustomize

ADD deploy.sh /deploy.sh
RUN chmod +x /deploy.sh
ADD pre-deploy.sh /pre-deploy.sh
RUN chmod +x /pre-deploy.sh
ADD neo4j-ips.sh /neo4j-ips.sh
RUN chmod +x /neo4j-ips.sh

ADD base-infra /base-infra

ADD yaml /yaml
ADD neo4j /neo4j
ADD elasticsearch /elasticsearch

RUN apk update
RUN apk upgrade
RUN apk add --no-cache bash curl git jq unzip gettext
#RUN apk add --no-cache --virtual .build-deps g++ python3-dev libffi-dev openssl-dev
#RUN pip3 install aws-shell
RUN apk add wget ca-certificates openssl-dev --update-cache
RUN wget -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/1.15.0/yq_linux_amd64
RUN chmod 777 /usr/local/bin/yq
#RUN apk add --no-cache python2
#RUN ln -fs /usr/bin/python2.7 /usr/bin/python
#RUN apk update && apk add nodejs

CMD ["bash","/deploy.sh"]
