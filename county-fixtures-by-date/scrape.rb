#!/usr/bin/env ruby

require 'date'
require 'oga'
require 'open-uri'

CACHE_DIR = 'cache'
SEASONS = 1890..2021
TOURNAMENT = 'County Championship'

BASE = 'https://cricketarchive.com'
INDEX = '/Archive/Seasons/%d_ENG.html'

def fetch(url)
  cached = File.join(CACHE_DIR, url.gsub(/[^A-Za-z0-9_.]+/, '-'))

  if File.exist?(cached)
    open(cached).read
  else
    sleep 1

    URI.open(url).read.tap do |page|
      open(cached, 'w').puts(page)
    end
  end
end

def extract_row(row)
  date, teams = nil, nil

  row.css('td').each do |cell|
    text = cell.text.strip
    parsed = Date.strptime(text, '%d %b %Y') rescue nil

    if parsed
      date = parsed
    elsif text.include?(' v ')
      teams = text
    end
  end

  [date, teams]
end

fixtures = SEASONS.flat_map do |year|
  fixtures_link =
    Oga
      .parse_html(fetch("#{BASE}#{INDEX % [year]}"))
      .css('a')
      .find { |a| a.text.include?(TOURNAMENT) }

  next unless fixtures_link # WWI and WWII

  fixtures_path = fixtures_link.attr('href').value

  Oga
    .parse_html(fetch("#{BASE}#{fixtures_path}"))
    .css('img[src="/logos/cricketarchive/cricketball.gif"]')
    .map { |i| i.parent.parent }
    .map(&method(:extract_row))
end

puts fixtures
       .compact
       .group_by(&:first)
       .map { |d, f| [d.year, d.month, d.day, f.count, '"' + f.map(&:last).join(', ') + '"'].join(',') }
