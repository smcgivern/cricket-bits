#!/usr/bin/env ruby

require "dijkstra_fast"
require "sqlite3"

db = SQLite3::Database.new "innings.sqlite3"

sources = db.execute("SELECT DISTINCT(player_id) FROM men_test_batting_innings WHERE start_date = '1877-03-15';").flatten
sinks = db.execute("SELECT DISTINCT(player_id) FROM men_test_batting_innings WHERE start_date >= '2023-01-01';").flatten
match_players = db.execute("SELECT match_id, player_id FROM men_test_batting_innings;")
PLAYER_NAMES = db.execute("SELECT player_id, player FROM men_test_batting_innings GROUP BY 1;").to_h
BY_MATCH = match_players.group_by(&:first).to_h { |k, v| [k, v.map(&:last).uniq] }
BY_PLAYER = match_players.group_by(&:last).to_h { |k, v| [k, v.map(&:first).uniq] }

graph = DijkstraFast::Graph.new

def distance(player, lookup = BY_PLAYER)
  1
  # Use the below to weight by total matches played
  # lookup[player].length
end

BY_PLAYER.each do |player, matches|
  connections = matches.flat_map { |m| BY_MATCH[m] }.uniq - [player]

  connections.each { |c| graph.add(player, c, distance: distance(player)) }
end

sources.each { |p| graph.add("start", p, distance: distance(p)) }
sinks.each { |p| graph.add(p, "end", distance: distance(p)) }

_, path = graph.shortest_path("start", "end")
names = path[1..-2].map { |p| [PLAYER_NAMES[p], distance(p)] }

examples = path[1..-2].each_cons(2).to_a.map do |(a, b)|
  match_id = BY_MATCH.find { |m, ps| ps.include?(a) && ps.include?(b) }[0]

  "https://www.espncricinfo.com/ci/content/match/#{match_id[1..-1]}.html"
end

p names.map(&:last).sum
p names
p examples
