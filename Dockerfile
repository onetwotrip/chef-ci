FROM ruby:2.3

RUN mkdir /root/.chef
COPY ./config/knife.rb /root/.chef/

RUN mkdir /opt/chef-ci
COPY . /opt/chef-ci

RUN cd /opt/chef-ci; gem install bundler; bundle install
ENV PATH /opt/chef-test/bin:$PATH

WORKDIR /workdir
