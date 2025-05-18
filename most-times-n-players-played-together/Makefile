.PHONY: run

run: data.csv
	cargo run

data.csv: innings.sqlite3
	sqlite3 -csv innings.sqlite3 'SELECT player, match_id, team FROM men_test_batting_innings GROUP BY 1, 2, 3' > data.csv
