FROM ruby:2.3

RUN echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config && \
  git config --global user.email "jenkins@ci.twiket.com" && \
  git config --global user.name "Jenkins"


RUN mkdir /root/.chef
COPY ./config/knife.rb /root/.chef/
COPY ./templates/twiket-bootstrap /twiket-bootstrap

RUN mkdir /opt/chef-ci
COPY . /opt/chef-ci

RUN cd /opt/chef-ci; gem install bundler; bundle install
ENV PATH /opt/chef-ci/bin:$PATH

WORKDIR /workdir
