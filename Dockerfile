FROM ruby:2.1.10

RUN apt update
RUN apt -y install libreoffice

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD ["bash", "-c", "bundle exec rackup -p $PORT config.ru"]