


---- Match Level Summary


SELECT 
    m.match_id,
    m.match_date,
    v.venue_name,
    t.team_name AS winning_team_name
    
    
FROM match m JOIN venue v ON (m.venue_id = v.venue_id)
             JOIN result r ON (m.match_id = r.match_id)
             JOIN team t ON (r.winning_team_id = t.team_id)

------ Innings Summary - Total Runs & Wickets

SELECT i.match_id,
       i.innings_no,
       t.team_name,
       SUM(s.runs_off_bat +  s.extras) AS total_runs,
       COUNT(wicket_type) AS total_wickets,
       COUNT(wides) AS number_of_wides,
       COUNT(*) - COUNT(wides) + COUNT(noballs) AS number_of_valid_balls,
       MOD((COUNT(*) - COUNT(wides) + COUNT(noballs)) ,6) as number_of_remaining_balls


FROM innings i JOIN team t ON (i.batting_team_id = t.team_id)
                 JOIN score_by_ball s ON (i.match_id = s.match_id AND i.innings_no = s.innings_no)
GROUP BY i.match_id,
          i.innings_no,
          t.team_name;


-------- - Innings Summary - Total Overs

SELECT 
    i.match_id,
    i.innings_no,
    t.team_name,
    SUM(s.runs_off_bat) + SUM(s.extras) as total_runs,
    COUNT(wicket_type) as total_wickets
FROM 
    innings i JOIN team t ON (i.batting_team_id = t.team_id)
              JOIN score_by_ball s ON (i.match_id = s.match_id AND i.innings_no = s.innings_no)
GROUP BY i.match_id,
    i.innings_no,
    t.team_name;


-------- Batting Scorecard - Player Level

SELECT 
    i.match_id,
    i.innings_no,
    t.team_name AS batting_team_name,
    p.player_name AS batsman_name,
    sum(runs_off_bat) AS total_runs,
    COUNT(*) AS total_balls,
    SUM(IIF(s.runs_off_bat =4, 1,0)) as no_of_fours,
    SUM(IIF(s.runs_off_bat =6, 1,0)) as no_of_sixs,
    FORMAT("%.2f",(CAST(sum(runs_off_bat) as REAL) / CAST(count(*) as REAL)) * 100) as strike_rate
FROM innings i JOIN team t ON (i.batting_team_id = t.team_id)
               JOIN score_by_ball s ON (i.match_id = s.match_id AND i.innings_no = s.innings_no)
               JOIN player p ON (s.striker_id = p.player_id)
WHERE s.wides IS NULL AND s.noballs IS NULL


GROUP BY    i.match_id,
            i.innings_no,
            t.team_name,
            p.player_name
ORDER BY  i.match_id,
            i.innings_no,
            MIN(s.ball_no);


