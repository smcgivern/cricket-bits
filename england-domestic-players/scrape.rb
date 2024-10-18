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
  46406, # Thunder
  46405, # Lightning
  39052, # Vipers
  46404, # Stars
  39053, # Storm
  46408, # Diamonds
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

TEAMS.each do |id|
  dir = id / 1000
  team_base = "#{BASE}/Archive/Teams/#{dir}/#{id}/"
  index = Oga.parse_html(fetch("#{team_base}Players.html"))
  team = index
           .at_css('h2')
           .text
           .gsub(' Players', '')
           .gsub('Players who have played for ', '')
           .gsub(/ (England|Wales)/, '')

  index.css('#columnLeft center a').each do |player_index_link|
    href = player_index_link.attr('href').value
    Oga
      .parse_html(fetch("#{href.start_with?('/') ? BASE : team_base}#{href}"))
      .css('#columnLeft td a')
      .each do |player_link|
        next unless player_link.attr('href').value.include?('/Players/')
        next if player_link.text.include?('of the Year')
        name = player_link.text.strip
        url = "#{BASE}#{player_link.attr('href')}"
        PLAYERS[url] ||= { name: name, teams: [] }
        PLAYERS[url][:teams] << team
      end
  end
end

PLAYERS.keys.sort.each do |player|
  puts [player, PLAYERS[player][:name], PLAYERS[player][:teams].uniq.sort.join('; ')].join(',')
end
