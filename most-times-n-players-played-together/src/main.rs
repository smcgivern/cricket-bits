use std::collections::{HashMap, HashSet};
use itertools::Itertools;
use std::fs::File;
use csv::ReaderBuilder;

fn print_groups(n: usize) {
    let filename = "data.csv";
    let file = File::open(filename).expect("Cannot open input file");
    let mut rdr = ReaderBuilder::new()
        .has_headers(false)
        .from_reader(file);

    // (match_id, team) → Set<player_id>
    let mut team_match_players: HashMap<(String, String), HashSet<String>> = HashMap::new();

    for result in rdr.records() {
        let record = result.expect("Invalid record");
        let player = record[0].trim().to_string();
        let match_id = record[1].trim().to_string();
        let team = record[2].trim().to_string();

        team_match_players
            .entry((match_id, team))
            .or_insert_with(HashSet::new)
            .insert(player);
    }

    let mut group_counts: HashMap<Vec<String>, usize> = HashMap::new();

    for ((_match_id, _team), players) in &team_match_players {
        if players.len() < n { continue; }

        let mut player_list: Vec<String> = players.iter().cloned().collect();
        player_list.sort();  // consistent key order

        for combo in player_list.into_iter().combinations(n) {
            *group_counts.entry(combo).or_insert(0) += 1;
        }
    }

    // Sort and print top groups
    let mut group_vec: Vec<_> = group_counts.into_iter().collect();
    group_vec.sort_by(|a, b| b.1.cmp(&a.1));  // Descending

    for (group, count) in group_vec.iter().take(3) {
        println!("{} matches: {}", count, group.join(", "));
    }
}

fn main() {
    for i in (4..=11).rev() {
        println!("{} players:", i);
        print_groups(i);
        println!("");
    }
}
