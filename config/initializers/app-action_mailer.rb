header_defaults = {}
header_defaults[:from] = ENV['MAIL_DEFAULT_FROM'] if ENV['MAIL_DEFAULT_FROM'].present?
header_defaults[:bcc] = ENV['MAIL_DEFAULT_BCC'] if ENV['MAIL_DEFAULT_BCC'].present?
ActionMailer::Base.default(header_defaults) if header_defaults.present?

url_defaults = {}
url_defaults[:host] = ENV['MAIL_DEFAULT_URL_HOST'] if ENV['MAIL_DEFAULT_URL_HOST'].present?
url_defaults[:protocol] = 'https' if ENV['MAIL_DEFAULT_URL_HTTPS'] == 'TRUE'
ActionMailer::Base.default_url_options = url_defaults if url_defaults.present?

if ENV['DEV_MAIL_DISABLED'] == 'TRUE'
  ActionMailer::Base.delivery_method = :test
elsif !Rails.env.test?
  ActionMailer::Base.delivery_method = :smtp
end

ActionMailer::Base.raise_delivery_errors = true

ActionMailer::Base.smtp_settings = {
  address: ENV['SMTP_HOST'],
  port: ENV['SMTP_PORT'].to_i,
  domain: ENV['SMTP_DOMAIN'],
  user_name: ENV['SMTP_USERNAME'],
  password: ENV['SMTP_PASSWORD'],
  authentication: 'plain',
  enable_starttls_auto: true,
}

if Rails.env.development? || ENV['DEV_MAIL_INTERCEPTOR'].present?
  class DevMailInterceptor
    def self.delivering_email(message)
      message.subject = "DEV:#{message.header[:to]}|#{message.subject}"
      message.to = ENV['DEV_MAIL_INTERCEPTOR'].presence || 'root@localhost'
    end
  end
  ActionMailer::Base.register_interceptor(DevMailInterceptor)
end
