#!/usr/bin/env ruby

require 'date'
require 'oga'
require 'open-uri'

CACHE_DIR = 'cache'
BASE = 'https://cricketarchive.com'
START = "/Archive/Grounds/11/462_f.html"

def fetch(path)
  url = "#{BASE}#{path}"
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

results = {}

Oga
  .parse_html(fetch(START))
  .css('#mainColumnContainerLeft a[href^="/Archive/Scorecards"]')
  .each do |match_link|
    Oga
      .parse_html(fetch(match_link.attr('href').value))
      .css('.candyRowA, .candyRowB')
      .each do |row|
        cells = row.css('td')
        if cells.length == 8
          player = cells[0].text.strip.sub(/[\*\+]+/, '')
          not_out = cells[1].text.strip == 'not out'

          if cells[1].text.strip != 'did not bat'
            results[player] ||= [0, 0, 0]
            results[player][0] += 1
            results[player][1] += cells[2].text.strip.to_i
            results[player][2] += not_out ? 1 : 0
          end
        end
      end
  end

sorted = results.map do |player, (innings, runs, not_outs)|
  average = (innings - not_outs) > 0 ? (runs.to_f / (innings - not_outs)).round(2) : ''
  [player, innings, runs, average]
end

puts 'Player,Innings,Runs,Average'
puts sorted.sort_by { |row| row[2] }.reverse.map { |row| row.join(',') }.join("\n")
