-- SELECT relevant columns from Match, Country, League, and Teams tables
SELECT
      m.id,
      c.name AS country,
      l.name AS league,
      m.season,
      m.match_api_id,
      m.home_team_api_id,
      t1.team_long_name AS home_team,
      m.away_team_api_id,
      t2.team_long_name AS away_team,
      m.home_team_goal,
      m.away_team_goal,
      m.foulcommit,
      m.card
FROM match AS m
JOIN country AS c
ON m.country_id = c.id
JOIN league AS l
ON m.league_id = l.id
JOIN team AS t1
ON m.home_team_api_id = t1.team_api_id
JOIN team AS t2
ON m.away_team_api_id = t2.team_api_id
ORDER BY 4;

-- Create view of combined tables
CREATE VIEW combined AS SELECT
      m.id,
      c.name AS country,
      l.name AS league,
      m.season,
      m.match_api_id,
      m.home_team_api_id,
      t1.team_long_name AS home_team,
      m.away_team_api_id,
      t2.team_long_name AS away_team,
      m.home_team_goal,
      m.away_team_goal,
      m.foulcommit,
      m.card,
      CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0
      END AS win_home,
      CASE WHEN m.home_team_goal < m.away_team_goal THEN 1 ELSE 0
      END AS win_away,
      CASE WHEN m.home_team_goal = m.away_team_goal THEN 1 ELSE 0
      END AS tie
FROM match AS m
JOIN country AS c
ON m.country_id = c.id
JOIN league AS l
ON m.league_id = l.id
JOIN team AS t1
ON m.home_team_api_id = t1.team_api_id
JOIN team AS t2
ON m.away_team_api_id = t2.team_api_id
ORDER BY 4;

-- Create Home Team records Table
SELECT
				home_team AS team,
				season,
        country,
        league,
        SUM(home_team_goal) AS goals_scored,
        SUM(away_team_goal) AS goals_against,
				SUM(win_home) AS wins,
				SUM(win_away) AS losses,
				SUM(tie) AS ties
FROM combined
GROUP BY 1, 2
ORDER BY 2;

-- Create Away Team records Table
SELECT
        away_team AS team,
        season,
        SUM(away_team_goal) AS goals_scored,
        SUM(home_team_goal) AS goals_against,
        SUM(win_away) AS wins,
				SUM(win_home) AS losses,
				SUM(tie) AS ties
FROM combined
GROUP BY 1, 2
ORDER BY 2;

-- Create total wins/losses/ties/goals_scored/goals_against table
with t1 AS (
  SELECT
  				home_team AS team,
  				season,
          country,
          league,
          SUM(home_team_goal) AS goals_scored,
          SUM(away_team_goal) AS goals_against,
  				SUM(win_home) AS wins,
  				SUM(win_away) AS losses,
  				SUM(tie) AS ties
  FROM combined
  GROUP BY 1, 2
  ORDER BY 2
),

t2 AS (
  SELECT
        away_team AS team,
        season,
        SUM(away_team_goal) AS goals_scored,
        SUM(home_team_goal) AS goals_against,
        SUM(win_away) AS wins,
				SUM(win_home) AS losses,
				SUM(tie) AS ties
FROM combined
GROUP BY 1, 2
ORDER BY 2)

SELECT t1.team,
       t1.season,
       t1.country,
       t1.league,
       t1.goals_scored + t2.goals_scored AS goals_scored,
       t1.goals_against + t2.goals_against AS goals_against,
       t1.wins + t2.wins AS wins,
       t1.losses + t2.losses AS losses,
       t1.ties + t2.ties AS ties
FROM t1
JOIN t2
ON t1.team = t2.team AND t1.season = t2.season
ORDER BY 2, 1;
