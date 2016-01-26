# PRODUCTION
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
  # config.assets.compile = false

  # Generate digests for assets URLs
  # Fingerprinting is enabled by default for production and disabled for all other environments.
  # You can enable or disable it in your configuration through the config.assets.digest option.
  # config.assets.digest = true

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
      :address => 'localhost',
      :domain => 'cornell.edu',
      :user_name => 'culsearch@cornell.edu'
      # :address => 'appsmtp.mail.cornell.edu',
      # :domain => 'cornell.edu',
      # :user_name => 'culsearch@cornell.edu'
  }
  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

end

# DEVELOPMENT
# BlacklightCornell::Application.configure do
#   # Settings specified here will take precedence over those in config/application.rb
#   config.eager_load = false
#   #config.eager_load = true
#
#   # In the development environment your application's code is reloaded on
#   # every request. This slows down response time but is perfect for development
#   # since you don't have to restart the web server when you make code changes.
#   config.cache_classes = false
#
#   # Log error messages when you accidentally call methods on nil.
#   config.whiny_nils = true
#
#   # Show full error reports and disable caching
#   config.consider_all_requests_local       = true
#   config.action_controller.perform_caching = false
#
#   # Don't care if the mailer can't send
#   config.action_mailer.raise_delivery_errors = true
#   config.action_mailer.delivery_method = :sendmail
#   config.action_mailer.smtp_settings = {
#       :address => 'localhost',
#       :domain => 'cornell.edu',
#       :user_name => 'culsearch@cornell.edu'
#   }
#
#   # Print deprecation notices to the Rails logger
#   config.active_support.deprecation = :log
#   # See everything in the log (default is :info)
#   config.log_level = ENV["LOG_LEVEL"].blank?  ? :debug : ENV["LOG_LEVEL"].to_sym
#
#   # Only use best-standards-support built into browsers
#   config.action_dispatch.best_standards_support = :builtin
#
#   # Raise exception on mass assignment protection for Active Record models
#   #config.active_record.mass_assignment_sanitizer = :strict
#   #config.active_record.mass_assignment_sanitizer = false
#
#   # Log the query plan for queries taking more than this (works
#   # with SQLite, MySQL, and PostgreSQL)
#   #  config.active_record.auto_explain_threshold_in_seconds = 0.5
#
#   # Do not compress assets
#   config.assets.compress = false
#
#   # Expands the lines which load the assets
#   config.assets.debug = true
#
#   # this allows WEBrick to handle pipe symbols in query parameters
#   URI::DEFAULT_PARSER =
#       URI::Parser.new(:UNRESERVED => URI::REGEXP::PATTERN::UNRESERVED + '|')
# end
