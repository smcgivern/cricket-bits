#!/usr/bin/env ruby

require "sqlite3"

DB = SQLite3::Database.new("innings.sqlite3")

def print_results(gender, format, min)
  runs_per_innings = DB.execute("SELECT match_id, innings, team, group_concat(runs) FROM #{gender}_#{format}_batting_innings WHERE runs IS NOT NULL GROUP BY 1, 2, 3;")

  with_consecutive = runs_per_innings.map do |(match, innings, team, runs)|
    runs_sorted = runs.split(",").map(&:to_i).sort.reverse
    top_score = runs_sorted.first
    consecutive = runs_sorted.to_enum.with_index.take_while { |runs, i| runs == top_score - i }
    match_url = "https://www.espncricinfo.com/ci/content/match/#{match[1..-1]}.html"

    [match_url, innings, team, runs_sorted, consecutive.length]
  end

  puts "#{gender} #{format}"
  with_consecutive.sort_by(&:last).reverse.take_while { |r| r.last >= min }.each { |r| p r }
end

genders = ["men", "women"]
formats = ["test", "odi", "t20i"]

genders.product(formats).each do |(gender, format)|
  print_results(gender, format, 3)
end
