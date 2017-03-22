# Craigslist Scraper Server

This is a small server to view leads scraped from Craigslist.  It's not very
REST-ful - or even very well written - but it gets the job done.

## Setup

Copy `docker-compose.env.sample` to `docker-compose.env` and fill in the
environment variables.  Once that's done, just run `docker-compose up --build`
to build the container and bring the server up.
