#!/usr/bin/env ruby

require 'json'

MOST_FC_RUNS = [
  '61760', '58959', '57611', '55061', '54211', '50670', '50551',
  '48426', '47793', '44846', '43551', '43423', '42719', '41284',
  '41112', '40140', '39969', '39832', '39790', '39405', '38942',
  '38874', '37897', '37665', '37354', '37252', '37248', '37002',
  '36965', '36673', '36549', '36440', '36356', '36212', '36049',
  '36012', '35725', '35659', '35208', '34994', '34843', '34378',
  '34346', '34101', '33660', '33519', '33128', '32650', '32502',
  '32150', '31914', '31847', '31716', '31714', '31232', '31091',
  '30886', '30874', '30573', '30546', '30225', '30225',
]

def overs(file)
  json = JSON.parse(open(file).read)

  candidates = json['innings'].map do |innings|
    innings['overs'].select do |over|
      match?(over['deliveries'])
    end
  end

  players = candidates.select(&:any?).flat_map do |overs|
    overs.map { |o| o['deliveries'][0].values_at('batter', 'bowler') }
  end

  if players.any?
    pp [json['info']['dates'].first, json['info']['event'], players]
  end
end

def match?(deliveries)
  return false if deliveries.any? { |d| d['wickets']&.any? }

  runs = deliveries.map { |d| d['runs']['total'] }

  return false unless runs.length == 6

  runs[0] != 0 && runs[1] != 0 && runs[2] != 0 && runs[3] == 0 && runs[4] != 0 && runs[5] != 0 &&
    MOST_FC_RUNS.include?("#{runs[0]}#{runs[1]}#{runs[1]}#{runs[4]}#{runs[5]}") &&
    p("#{runs[0]}#{runs[1]}#{runs[1]}#{runs[4]}#{runs[5]}")
end

Dir["#{ARGV[0]}/*.json"].each do |file|
  overs(file)
end
