FROM ruby:3.0.6

ENV LANG C.UTF-8

RUN apt-get update
RUN apt-get -y install tzdata
RUN ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN gem install bundler -v '2.3.14'
RUN bundle install

COPY . /app
