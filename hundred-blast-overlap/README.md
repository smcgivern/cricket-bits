# Hundred and Blast overlap

Of the players who played in both The Hundred and the T20 Blast, what were the
aggregate figures for each competition? The intent is to approximate which
competition is stronger, by using only the same players.

We can also calculate the players who improved the most from one to the other,
in both directions.

First, install SQLite (if you use Nix and direnv, this will happen
automatically). Then:

```shell
$ ./create-db
$ ./query-db
2021 overall
hundred_runs,hundred_average,hundred_strike_rate,blast_runs,blast_average,blast_strike_rate
7656,22.65,1.38,18195,26.26,1.42

2021 top Hundred scorers
player,hundred_runs,hundred_average,hundred_strike_rate,blast_runs,blast_average,blast_strike_rate
"LS Livingstone",348,58.0,1.78,279,55.8,1.48
"BM Duckett",232,29.0,1.37,383,34.82,1.58
"JM Vince",229,28.63,1.29,373,31.08,1.36
"MM Ali",225,32.14,1.48,106,26.5,1.45
"GD Phillips",214,35.67,1.47,500,55.56,1.63
"DJ Malan",214,26.75,1.22,41,10.25,1.05
"AL Davies",202,28.86,1.33,260,20.0,1.29
"HC Brook",189,47.25,1.54,486,69.43,1.49
"JJ Roy",186,37.2,1.49,139,34.75,1.48
"AD Hales",185,23.13,1.32,482,43.82,1.79

2021 top Blast scorers (excluding above)
player,hundred_runs,hundred_average,hundred_strike_rate,blast_runs,blast_average,blast_strike_rate
"JP Inglis",173,24.71,1.36,531,48.27,1.76
"DJ Bell-Drummond",32,10.67,0.89,492,37.85,1.56
"JM Clarke",127,18.14,1.51,408,37.09,1.81
"FH Allen",165,20.63,1.5,399,33.25,1.6
"SR Hain",12,,1.0,398,39.8,1.39
"JL du Plooy",147,24.5,1.41,395,39.5,1.31
"WG Jacks",146,20.86,1.76,393,35.73,1.7
"WCF Smeed",166,33.2,1.73,385,32.08,1.32
"Z Crawley",64,64.0,1.6,380,31.67,1.51
"LM Reece",24,12.0,0.96,351,29.25,1.71

2022 overall
hundred_runs,hundred_average,hundred_strike_rate,blast_runs,blast_average,blast_strike_rate
7913,23.14,1.4,19493,25.89,1.46

2022 top Hundred scorers
player,hundred_runs,hundred_average,hundred_strike_rate,blast_runs,blast_average,blast_strike_rate
"DJ Malan",377,53.86,1.67,234,29.25,1.37
"PD Salt",353,39.22,1.53,390,27.86,1.47
"A Lyth",299,37.38,1.76,525,35.0,1.77
"WG Jacks",261,43.5,1.72,449,32.07,1.42
"AD Hales",259,28.78,1.52,374,26.71,1.94
"BM Duckett",220,31.43,1.36,396,36.0,1.6
"C Munro",206,41.2,1.69,323,26.92,1.33
"JC Buttler",203,40.6,1.49,42,42.0,1.45
"SM Curran",192,27.43,1.32,236,29.5,1.47
"JM Cox",191,38.2,1.44,365,28.08,1.33

2022 top Blast scorers (excluding above)
player,hundred_runs,hundred_average,hundred_strike_rate,blast_runs,blast_average,blast_strike_rate
"JM Vince",136,22.67,1.55,678,48.43,1.46
"RR Rossouw",70,11.67,1.13,623,47.92,1.92
"AJ Hose",182,30.33,1.6,557,55.7,1.61
"WL Madsen",157,22.43,1.22,499,38.38,1.65
"BR McDermott",157,31.4,1.33,494,29.06,1.46
"MS Pepper",77,19.25,1.22,439,36.58,1.63
"HC Brook",85,21.25,1.39,436,39.64,1.64
"WCF Smeed",179,25.57,1.72,407,27.13,1.58
"TH David",84,16.8,1.47,405,28.93,1.75
"PI Walter",82,11.71,1.67,404,44.89,1.52
```
