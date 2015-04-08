web: bundle exec puma -p $PORT -t 2:3
worker: bundle exec rake jobs:work
hourly: bundle exec rake app:hourly
daily: bundle exec rake app:daily
