#!/usr/bin/env ruby

require 'date'
require 'oga'
require 'open-uri'

CACHE_DIR = 'cache'
BASE = 'https://cricketarchive.com'
PLAYERS = {}

TEAMS = [
  78, # Derbyshire
  90, # Durham
  101, # Essex
  115, # Glamorgan
  118, # Gloucestershire
  130, # Hampshire
  170, # Kent
  184, # Lancashire
  186, # Leicestershire
  210, # Middlesex
  238, # Northamptonshire
  243, # Nottinghamshire
  326, # Somerset
  344, # Surrey
  346, # Sussex
  387, # Warwickshire
  399, # Worcestershire
  404, # Yorkshire
  39506, # Lancashire Thunder
  46406, # Thunder
  39054, # Loughborough Lightning
  46405, # Lightning
  50235, # The Blaze
  39052, # Vipers
  39055, # Surrey Stars
  46404, # Stars
  39053, # Storm
  2971, # Diamonds
  39051, # Yorkshire Diamonds
  46408, # Northern Diamonds
  46409, # Sunrisers
  46407, # Central Sparks
  20, # Australia
  23, # Australia women
  523, # Bangladesh
  4597, # Bangladesh women
  796, # India
  806, # India women
  992, # New Zealand
  1008, # New Zealand women
  263, # Pakistan
  1098, # Pakistan women
  1235, # South Africa
  1244, # South Africa women
  320, # Sri Lanka
  1285, # Sri Lanka women
  1356, # West Indies
  1364, # West Indies women
  407, # Zimbabwe
  3613, # Zimbabwe women

]

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

TEAMS.each do |id|
  dir = id / 1000
  team_base = "#{BASE}/Archive/Teams/#{dir}/#{id}/"
  index = Oga.parse_html(fetch("#{team_base}Players.html"))
  team = index
           .at_css('h2')
           .text
           .gsub(' Players', '')
           .gsub('Players who have played for ', '')
           .gsub(/ \((England|Wales)\)/, '')

  if index.css('#columnLeft center>a').length == 0
    find_players(team, index)
  else
    index.css('#columnLeft center>a').each do |player_index_link|
      href = player_index_link.attr('href').value
      find_players(
        team,
        Oga.parse_html(fetch("#{href.start_with?('/') ? BASE : team_base}#{href}"))
      )
    end
  end
end

PLAYERS.keys.sort.each do |player|
  puts [player, PLAYERS[player][:name], PLAYERS[player][:teams].uniq.sort.join('; ')].join(',')
end
