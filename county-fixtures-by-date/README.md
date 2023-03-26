# County fixtures by date

[CricketArchive] is paywalled, but seems to allow scraping. (The site
requires JavaScript, and uses JavaScript to enforce the paywall.)

This script grabs the index page for all English seasons from 1890 to
2021, then gets the fixtures table for that year by finding the first
link on the page containing 'County Championship'. It then converts that
table to a CSV with these columns:

1. Year
2. Month
3. Day
4. Number of matches
5. Match details ('A v B, C v D')

```shell
bundle
./scrape.rb
```

[CricketArchive]: https://cricketarchive.com/
