FROM ruby:2.3.3-alpine

WORKDIR /data/amdirent/craigslist

COPY Gemfile* ./

RUN apk add --no-cache build-base postgresql-dev \
    && bundle install \
    && apk del build-base postgresql-dev \
    && apk add --no-cache libcurl postgresql

COPY setup.rb config.ru ./
COPY lib/ lib/
COPY config/ config/
COPY public/ public/
COPY protected/ protected/
COPY views/ views/

EXPOSE 5000

ENTRYPOINT ["bundle", "exec"]
CMD ["puma -p 5000"]
