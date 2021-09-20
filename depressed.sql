-- 1. 最新のreportsでemotion = 1のユーザーのreport
select
  reports.user_id, reports.emotion, reports.reported_on
from
  (select user_id, max(reported_on) as A from reports group by user_id) as X -- user_idごとの最新の日付を取ってくる
join
  reports on X.user_id = reports.user_id and A = reports.reported_on where reports.emotion = 1 order by reports.user_id;


-- 2. 1番目のreportでemotion = 1のユーザーの2番目のreport
select
  reports.user_id, max(reports.reported_on)
from
  (
    select
      reports.user_id, reports.emotion, reports.reported_on
    from
      (select user_id, max(reported_on) as A from reports group by user_id) as X
    join
      reports on X.user_id = reports.user_id and A = reports.reported_on where reports.emotion = 1 order by reports.user_id
  ) as Y
join
  reports on Y.user_id = reports.user_id and Y.reported_on > reports.reported_on group by reports.user_id order by reports.user_id;


-- 3. 1番目のreportでemotion = 1のユーザーの、2番目のreportのemotino = 1のユーザーを取ってくる（最終データ）
select
  reports.user_id, reports.emotion, reports.reported_on
from
  (
    select
      reports.user_id, max(reports.reported_on) as B
    from
      (
        select
          reports.user_id, reports.emotion, reports.reported_on
        from
          (select user_id, max(reported_on) as A from reports group by user_id) as X
        join
          reports on X.user_id = reports.user_id and A = reports.reported_on where reports.emotion = 1 order by reports.user_id
      ) as Y
    join
      reports on Y.user_id = reports.user_id and Y.reported_on > reports.reported_on group by reports.user_id order by reports.user_id
  ) as Z
join
  reports on Z.user_id = reports.user_id and B = reports.reported_on where reports.emotion = 1 order by reports.user_id;


-- 4. をwith句で読みやすくする
WITH
  X AS (
    SELECT user_id, max(reported_on) AS A FROM reports GROUP BY user_id -- 最新の日付を取ってくる
  ),
  Y AS (
    SELECT reports.user_id, reports.emotion, reports.reported_on -- emotion = 1 を撮ってくる
    FROM X
    JOIN reports ON X.user_id = reports.user_id and A = reports.reported_on WHERE reports.emotion = 1 ORDER BY reports.user_id
  ),
  Z AS (
    SELECT reports.user_id, max(reports.reported_on) AS B -- 2番めに新しい日付をとってくる
    FROM Y
    JOIN reports ON Y.user_id = reports.user_id and Y.reported_on > reports.reported_on GROUP BY reports.user_id ORDER BY reports.user_id
  )
SELECT
  reports.user_id, reports.emotion, reports.reported_on -- 2番めに新しい日付がemotion = 1ならデータをとってくる
FROM Z
JOIN reports ON Z.user_id = reports.user_id and B = reports.reported_on WHERE reports.emotion = 1 ORDER BY reports.user_id;
