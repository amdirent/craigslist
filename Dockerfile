FROM ruby:2.3.3-alpine

WORKDIR /data/amdirent/craigslist

COPY Gemfile* ./

RUN apk add --no-cache build-base postgresql-dev libxslt-dev libffi-dev \
    && gem install bundler \
    && bundle install \
    && apk del build-base postgresql-dev libxslt-dev libffi-dev \
    && apk add --no-cache libcurl libffi libxslt postgresql

COPY spider_posts qualify_posts ./
COPY lib/ lib/

CMD ["./spider_posts"]
