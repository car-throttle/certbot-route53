FROM ubuntu:16.04

ENV TZ ${TZ:-"Europe/London"}
RUN apt-get update && apt-get upgrade -y \
  && apt-get install --no-install-recommends -y locales \
  && echo "$TZ" | tee /etc/timezone \
  && ln -fs "/usr/share/zoneinfo/$TZ" /etc/localtime

# Set the locale for UTF-8 support
RUN echo en_US.UTF-8 UTF-8 >> /etc/locale.gen && \
    locale-gen && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV PYTHONIOENCODING=UTF-8

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    less \
    man \
    ssh \
    python \
    python-pip \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && pip install setuptools virtualenv \
  && pip install awscli \
  && pip install certbot

ENTRYPOINT [ "/bin/bash" ]
WORKDIR /root
VOLUME /root/.aws
VOLUME /root/letencrypt

COPY certbot-route53.sh .
RUN chmod a+x /root/certbot-route53.sh
