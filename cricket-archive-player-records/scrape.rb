#!/usr/bin/env ruby

require 'date'
require 'oga'
require 'open-uri'

CACHE_DIR = 'cache'
HEADER_REGEX = /.*?(?<format>(First-Class|List A|Twenty20)) Career (?<discipline>(Batting|Bowling))/
EMPTY_MATCH = { format: nil, discipline: nil }

def fetch(url)
  cached = File.join(CACHE_DIR, url.gsub(/[^A-Za-z0-9_.]+/, '-'))

  if File.exist?(cached)
    open(cached).read.scrub
  else
    sleep 1

    URI.open(url).read.scrub.tap do |page|
      open(cached, 'w').puts(page)
    end
  end
end

def find_players(team, page)
  page.css('#columnLeft td a').each do |player_link|
    href = player_link.attr('href').value
    name = player_link.text.strip
    url = "#{BASE}#{href}"

    next unless href.include?('/Players/')
    next if name.include?('of the Year')

    PLAYERS[url] ||= { name: name, teams: [] }
    PLAYERS[url][:teams] << team
  end
end

File.readlines('players.in', chomp: true).each do |url|
  stats = Oga.parse_html(fetch(url)).css('#columnLeft table').each_with_object({}) do |table, h|
    (table.at_css('td').text.match(HEADER_REGEX) || EMPTY_MATCH) => { format:, discipline: }

    next unless format && discipline

    index = discipline == 'Bowling' ? 4 : 5
    stats_row = table.css('tr').last.css('td').map { |c| c.text.strip }
    h[format] ||= {}
    h[format][discipline] = stats_row[1..index] + stats_row[7..8]
  end

  puts [
         url,
         stats.dig('First-Class', 'Batting') || Array.new(7),
         stats.dig('List A', 'Batting') || Array.new(7),
         stats.dig('Twenty20', 'Batting') || Array.new(6),
         stats.dig('First-Class', 'Bowling') || Array.new(6),
         stats.dig('List A', 'Bowling') || Array.new(6),
         stats.dig('Twenty20', 'Bowling') || Array.new(6),
       ].flatten.join(',')
end
