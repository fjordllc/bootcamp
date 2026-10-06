release: DB_STATEMENT_TIMEOUT_MS=0 bundle exec rake db:migrate
web: bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}
