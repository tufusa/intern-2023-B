FROM ruby:3.0.6

ENV LANG C.UTF-8

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ADD . /usr/src/app

RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y postgresql-client sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get -y install tzdata --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

ADD Gemfile /usr/src/app/
ADD Gemfile.lock /usr/src/app/
ADD start.sh /usr/src/app/bin/
RUN chmod +x /usr/src/app/bin/start.sh

RUN gem install bundler -v '2.3.14'
RUN bundle install

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
