FROM ruby:3.3.2

RUN apt-get update && apt-get install -y \
  vim-gtk3 \
RUN mkdir -p /app
WORKDIR /app
COPY Gemfile* ./
RUN gem install bundler -v 2.3.22 && bundle install --jobs 20 --retry 5
COPY . /app
RUN rm -rf tmp/*
ADD . /app

