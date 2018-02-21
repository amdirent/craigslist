# craigslist scraper
Set of scripts to scrape and qualify craigslist posts.  Designed to be run containerized with Docker.

## Tables

| posts | | |
| --- | --- | --- |
| url            | text | URL to the post |
| title          | text | Title of the post |
| title_ts       | tsvector | a ts vector of the title |
| body           | text | Body of the post |
| body_ts        | tsvector | a ts vector of the body |
| contact_email  | text | contact email listed on the post |
| contact_phone  | text | contact phone listed on the post |
| potential_lead | boolean | stores if the post is a potential lead.  Set using the auto-qualifier or the bundled server |
| processed      | boolean | stores if the post was processed with the old qualifier |
