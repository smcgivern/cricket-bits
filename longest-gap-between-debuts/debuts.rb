#!/usr/bin/env ruby

require "sqlite3"

DB = SQLite3::Database.new("innings.sqlite3")

def print_results(gender, format)
  debut_by_player = DB.execute("SELECT player_id, match_id, row_number() OVER(PARTITION BY player_id ORDER BY start_date) FROM #{gender}_#{format}_batting_innings;").
    select { |(player_id, match_id, rank)| rank == 1 }.
    to_h { |(player_id, match_id, rank)| [player_id, match_id] }

  matches_by_team = DB.execute("SELECT team, match_id, start_date FROM #{gender}_#{format}_team_innings GROUP BY team, match_id ORDER BY start_date;").
    group_by(&:first)

  streaks = []

  matches_by_team.values.each do |matches|
    matches_since_debut = 0

    matches.each do |(team, match_id, start_date)|
      players = DB.execute("SELECT DISTINCT player_id FROM #{gender}_#{format}_batting_innings WHERE match_id = '#{match_id}' AND team = '#{team}';")

      if players.any? { |(player_id)| debut_by_player[player_id] == match_id }
        streaks << [team, start_date, matches_since_debut] if matches_since_debut > 0
        matches_since_debut = 0
      else
        matches_since_debut += 1
      end
    end
  end

  puts ""
  puts "#{gender} #{format}"
  streaks.sort_by(&:last).reverse.take(10).each { |streak| p streak }
end

genders = ["men", "women"]
formats = ["test", "odi", "t20i"]

genders.product(formats).each do |(gender, format)|
  print_results(gender, format)
end
