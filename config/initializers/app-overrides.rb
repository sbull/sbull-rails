if Rails.env.development?
  Rails.logger = Logger.new(STDOUT) # Get logs to spit out when using foreman/puma.
  Rails.application.config.assets.debug = false
  # Enable concurrent requests.
  # http://stackoverflow.com/questions/21605318/how-can-i-serve-requests-concurrently-with-rails-4
  Rails.application.config.middleware.delete(Rack::Lock)
end

Rails.application.config.force_ssl = true
