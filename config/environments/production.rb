BlacklightCornell::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  #config.eager_load = false
  config.eager_load = true

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_files = false 

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  # Fingerprinting is enabled by default for production and disabled for all other environments. 
  # You can enable or disable it in your configuration through the config.assets.digest option.
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  #config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.smtp_settings = {
    :address => 'appsmtp.mail.cornell.edu',
    :domain => 'cornell.edu',
    :user_name => 'culsearch@cornell.edu'
  }
  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
  
  # Settings for the exception_notification gem
  Rails.application.config.middleware.use ExceptionNotification::Rack,
  # :email => {
  #   :email_prefix => "[ERROR] ",
  #   :sender_address => %{"notifier" <notifier@example.com>},
  #   :exception_recipients => %w{mjc12@cornell.edu}
  # },
  :hipchat => {
    :api_token => ENV['HIPCHAT_API_TOKEN'],
    :api_version => 'v2',
    :room_name => 'Discovery and Access'
  }

end
