Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 5
Delayed::Worker.max_attempts = 10
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.default_priority = 100
# Delayed::Worker.read_ahead = 5
Delayed::Worker.default_queue_name = 'default'
Delayed::Worker.delay_jobs = ENV['DELAY_JOBS'] == 'TRUE'

# Rails.application.config.active_job.queue_adapter = :delayed_job
ActiveJob::Base.queue_adapter = :delayed_job

# Devise::Async.backend = :delayed_job
