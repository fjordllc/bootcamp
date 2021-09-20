User Load (0.3ms)
SELECT
  "users".*
FROM
  "users"
WHERE
  "users"."job_seeking" = $ 1 [["job_seeking", true]]

Report Load (0.2ms)
SELECT "reports".* FROM "reports" WHERE "reports"."user_id" IN ($1, $2)  [["user_id", 784971462], ["user_id", 1038099145]]
