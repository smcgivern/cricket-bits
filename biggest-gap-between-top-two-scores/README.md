# Biggest gap between top two scores

[CricketArchive] is paywalled, but seems to allow scraping. (The site
requires JavaScript, and uses JavaScript to enforce the paywall.)

This script grabs the list of first class double centuries, and tries to
find the _second_ highest score for each player, in order to find the
biggest gap between a player's top two scores.

To find the player's second-highest score, we:

1. Look for another entry on the double-hundreds list.
2. If not, construct a query (with appropriate sleeps, to avoid
   hammering CricketArchive) for all the player's first class innings,
   and look it up from there.

It then outputs a CSV with:

1. Player name
2. Player link
3. High score
4. Second high score
5. High score link
6. Second high score link
7. Gap

```shell
asdf install
bundle
./scrape.rb
```

[CricketArchive]: https://cricketarchive.com/
