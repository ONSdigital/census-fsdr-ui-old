FROM ruby:2.5

WORKDIR /usr/src/app

COPY ./ ./
COPY config.ru ./
COPY Gemfile Gemfile.lock ./

RUN bundle install

EXPOSE 5678
CMD rackup -o 0.0.0.0 -p 5678
