#!/usr/bin/env ruby

require 'json'

TARGET = 24
NEEDS_FINAL_BALL_WIN = true

def find_streaks(file, candidates)
  json = JSON.parse(open(file).read)
  winner = json.dig('info', 'outcome', 'winner')
  chase = json.dig('innings', 1)

  return unless chase && winner && chase['team'] == winner
  return unless chase['overs'].count == 20
  return unless chase['overs'].last['deliveries'].count == 6

  non_boundary_count = 0
  starting_index = [nil, nil]
  chase['overs'].reverse.each.with_index do |over, i|
    over['deliveries'].reverse.each.with_index do |delivery, j|
      batter_runs = delivery['runs']['batter']
      if delivery['non_boundary'] || (batter_runs != 4 && batter_runs != 6)
        unless starting_index[0] && starting_index[1]
          starting_index = [i, j]
        end
        non_boundary_count += 1
      else
        if non_boundary_count >= TARGET
          if !NEEDS_FINAL_BALL_WIN || (starting_index[0] == 0 && starting_index[1] == 0)
            candidates << [chase['team'], json['info']['dates'][0], non_boundary_count, over['over']]
          end
        end
        starting_index = [nil, nil]
        non_boundary_count = 0
      end
    end
  end
end

candidates = []

Dir["#{ARGV[0]}/*.json"].each do |file|
  find_streaks(file, candidates)
end

candidates.sort_by { |x| x[2] }.reverse.each do |(team, date, non_boundaries, starting_over)|
  puts "#{non_boundaries}: #{team} on #{date} starting in over #{starting_over}"
end
