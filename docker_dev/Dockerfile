FROM ruby:3.0.2

MAINTAINER Maxim Zelenkin <nudepatch@gmail.com>

RUN apt update -q && apt install -y \
    nano > /dev/null

ENV APP_PATH /app
RUN mkdir -p $APP_PATH
WORKDIR $APP_PATH

ENV BUNDLE_PATH /bundle
ENV GEM_HOME /bundle
ENV PATH="/bundle/bin:${PATH}"

RUN gem install bundle

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
