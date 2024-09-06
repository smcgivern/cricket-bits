#!/usr/bin/env ruby

require 'json'

TARGET = 7

def find_streaks(file, candidates)
  json = JSON.parse(open(file).read)

  json['innings'].map do |innings|
    boundary_count = 0
    innings['overs'].each do |over|
      over['deliveries'].each do |delivery|
        batter_runs = delivery['runs']['batter']
        if (batter_runs == 4 || batter_runs == 6) && !delivery['non_boundary']
          boundary_count += 1
        else
          if boundary_count >= TARGET
            candidates << [innings['team'], json['info']['dates'][0], boundary_count, over['over']]
          end

          boundary_count = 0
        end
      end
    end
  end
end

candidates = []

Dir["#{ARGV[0]}/*.json"].each do |file|
  find_streaks(file, candidates)
end

candidates.sort_by { |x| x[2] }.reverse.each do |(team, date, boundaries, ending_over)|
  puts "#{boundaries}: #{team} on #{date} ending in over #{ending_over}"
end
