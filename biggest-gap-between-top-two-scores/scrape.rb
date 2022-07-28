#!/usr/bin/env ruby

require 'csv'
require 'date'
require 'oga'
require 'open-uri'

CACHE_DIR = 'cache'

DOUBLE_HUNDREDS = 'https://stats.acscricket.com/Records/First_Class/Overall/Batting/Double_Hundreds_by_Score.html'
INNINGS_QUERY = 'https://www.cricketarchive.com/cgi-bin/player_oracle_reveals_results1.cgi?searchtype=InningsList&playernumber='
BASE = 'https://cricketarchive.com'

def cache(key)
  cached = File.join(CACHE_DIR, key)

  if File.exist?(cached)
    open(cached).read
  else
    yield.tap do |result|
      open(cached, 'w').puts(result)
    end
  end
end

def fetch(url)
  cache(url.gsub(/[^A-Za-z0-9_.]+/, '-')) do
    sleep 1

    URI.open(url).read
  end
end

def url(cell)
  value = cell.at_css('a').attr('href').value

  if value.start_with?(BASE)
    value
  else
    BASE + value
  end
end

def extract_double_hundred(cell)
  score, player, match = *cell.parent.css('td')

  [
    player.text.strip,
    url(player),
    score.text.strip,
    url(match)
  ]
end

def extract_single_innings(cell)
  cells = cell.css('td')

  [
    cells[2].text.gsub(/[[:space:]]/, ''),
    cells[14] ? url(cells[14]) : ''
  ]
end

def valid_row?(row)
  cells = row.css('td')

  cells.length > 12 &&
    cells[2].text.to_i > 0 &&
    cells.last.text.gsub(/[[:space:]]/, '') != '' &&
    !cells.last.text.start_with?('misc')
end

def top_two(player, rows)
  [
    player,
    rows
      .sort_by { |(_player, score)| score.first.to_i }
      .reverse
      .take(2)
      .map(&:last)
  ]
end

def second_highest(player_url)
  player_id = player_url.match('(\d+).html')[1]

  innings =
    Oga
      .parse_html(fetch(INNINGS_QUERY + player_id))
      .css('#mainColumnContainerLeft tr')
      .select(&method(:valid_row?))
      .map(&method(:extract_single_innings))
      .sort_by { |(score, _url)| score.to_i }
      .reverse[1]
end

double_hundreds = CSV.parse(
  cache('double-hundreds.csv') do
    Oga
      .parse_html(fetch(DOUBLE_HUNDREDS))
      .css('.entry-content tr td:first-child[valign="top"]')
      .select { |c| c.text.to_i > 0 }
      .map(&method(:extract_double_hundred))
      .map { |r| r.join(',') }
      .join("\n")
  end
)

top_two =
  double_hundreds
    .map { |player, link, score, match_link| [[player, link], [score, match_link]] }
    .group_by(&:first)
    .to_h(&method(:top_two))

top_two.each do |player, scores|
  next if scores.length == 2

  scores << second_highest(player.last)
end

puts top_two
       .map { |(player, scores)| player + scores.flatten + [scores.first.first.to_i - (scores.last&.first.to_i)] }
       .sort_by(&:last)
       .reverse
       .take(50)
       .map { |r| r.join(',') }
       .join("\n")
