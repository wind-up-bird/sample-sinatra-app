FROM ruby:3.0.1-alpine

WORKDIR /app

COPY ./ /app

RUN bundle install

EXPOSE 4567
CMD ["bundle", "exec", "ruby", "main.rb"]
