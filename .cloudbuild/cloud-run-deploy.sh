#!/usr/bin/env bash
set -euo pipefail

environment=${1:?Usage: cloud-run-deploy.sh ENVIRONMENT}
image="asia.gcr.io/${PROJECT_ID}/${REPO_NAME}:${COMMIT_SHA}"

secret_ref() {
  local name
  name=$(echo "$1" | tr '[:upper:]_' '[:lower:]-')
  echo "$1=bootcamp-${environment}-${name}:latest"
}

join_by_comma() {
  local IFS=,
  echo "$*"
}

env_vars=(
  LANG=ja_JP.UTF-8
  TZ=Asia/Tokyo
  RAILS_SERVE_STATIC_FILES=true
  RAILS_LOG_TO_STDOUT=true
  RAILS_ENV=production
  RACK_ENV=production
  APP_HOST_NAME="${_APP_HOST_NAME}"
  CLOUD_RUN_HOST_NAME="${_CLOUD_RUN_HOST_NAME}"
  DB_NAME="${_DB_NAME}"
  DB_USER="${_DB_USER}"
  DB_HOST="/cloudsql/${_CLOUD_SQL_HOST}"
  GCS_BUCKET="${_GCS_BUCKET}"
  BASIC_AUTH_USER="${_BASIC_AUTH_USER}"
)

if [[ "$environment" == production ]]; then
  env_vars+=(RAILS_MAX_THREADS=5)
fi

secret_names=(
  RAILS_MASTER_KEY
  DB_PASS
  GOOGLE_CREDENTIALS
  TOKEN
  DISCORD_NOTICE_WEBHOOK_URL
  DISCORD_INTRODUCTION_WEBHOOK_URL
  DISCORD_ALL_WEBHOOK_URL
  DISCORD_ADMIN_WEBHOOK_URL
  DISCORD_MENTOR_WEBHOOK_URL
  DISCORD_BUG_WEBHOOK_URL
  DISCORD_REPORT_WEBHOOK_URL
  DISCORD_GUILD_ID
  DISCORD_TIMES_CHANNEL_CATEGORY_ID
  DISCORD_BOT_TOKEN
  MISSION_CONTROL_USERNAME
  MISSION_CONTROL_PASSWORD
  STRIPE_ENDPOINT_SECRET
  BASIC_AUTH_PASSWORD
  RECAPTCHA_SITE_KEY
  RECAPTCHA_SECRET_KEY
  ROLLBAR_CLIENT_TOKEN
  OPEN_AI_ACCESS_TOKEN
  ANTHROPIC_API_KEY
  PJORD_GITHUB_TOKEN
  STRIPE_TAX_RATE_ID
  DISCORD_CLIENT_ID
  DISCORD_CLIENT_SECRET
  DISCORD_AUTHENTICATION_URL
  PUBSUB_AUDIENCE
  PUBSUB_SERVICE_ACCOUNT_EMAIL
  PUBSUB_TOPIC
  GITHUB_KEY
  GITHUB_SECRET
  ROLLBAR_ACCESS_TOKEN
  SLACK_WEBHOOK_URL
  STRIPE_PUBLIC_KEY
  STRIPE_SECRET_KEY
  POSTMARK_API_TOKEN
)

secret_vars=()
for secret_name in "${secret_names[@]}"; do
  secret_vars+=("$(secret_ref "$secret_name")")
done

if [[ "$environment" == production ]]; then
  env_vars+=(PJORD_LLM_MODEL=claude-sonnet-4-6)
fi

args=(
  run
  deploy
  "${_SERVICE_NAME}"
  --platform=managed
  --region=asia-northeast1
  --quiet
  "--image=${image}"
  --allow-unauthenticated
  --clear-vpc-connector
  --add-cloudsql-instances
  "${_CLOUD_SQL_HOST}"
  --memory
  "${_MEMORY}"
  --timeout
  10m
  "--set-env-vars=$(join_by_comma "${env_vars[@]}")"
  "--set-secrets=$(join_by_comma "${secret_vars[@]}")"
  "--labels=managed-by=gcp-cloud-build-deploy-cloud-run,commit-sha=${COMMIT_SHA},gcb-build-id=${BUILD_ID},gcb-trigger-id=${_TRIGGER_ID},${_LABELS}"
)

if [[ "$environment" == production ]]; then
  args+=(--concurrency 5)
fi

gcloud "${args[@]}"
