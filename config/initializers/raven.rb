if Rails.env.production? || ENV['FORCE_ENABLE_SENTRY'] == 'true'
  Raven.configure do |config|
    config.dsn = Rails.application.secrets.sentry[:dsn]
    config.current_environment = ENV['ENV_NAME'] || config.current_environment
    config.server_name = ENV['NICKNAME'] || config.server_name
    if Rails.env.development?
      config.logger.level = :debug
    else
      config.logger.level = :warn
    end
  end
end
