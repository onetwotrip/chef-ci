FROM ruby:2.3

RUN mkdir /opt/nodeup
ADD . /opt/nodeup
WORKDIR /opt/nodeup

RUN bundle install
ENTRYPOINT bin/nodeup
