require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env) if defined?(Bundler)

class Class
  def is_indexed(*args, &block)
  end
end

module Ultrasphinx
  class Search
    def initialize(options = {})
    end

    def self.query_defaults=(defaults)
    end

    def self.query_defaults
      {}
    end

    def self.excerpting_options=(options)
    end

    def self.client_options
      {}
    end
  end

  class UsageError < StandardError
  end

  MAIN_INDEX = 1

  def self.delta_index_present?
  end
end

module Gitorious
  class Application < Rails::Application
    config.autoload_paths += [config.root.join('lib')]
    config.encoding = 'utf-8'
    gitorious_yaml = YAML.load_file(Rails.root + "config/gitorious.yml")[Rails.env]
    raise "Your config/gitorious.yml does not have an entry for your current Rails environment. Please consult config/gitorious.sample.yml for instructions." unless gitorious_yaml

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    # See Rails::Configuration for more options.

    # Skip frameworks you're not going to use. To use Rails without a database
    # you must remove the Active Record framework.
    # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

    # Only load the plugins named here, in the order given. By default, all plugins
    # in vendor/plugins are loaded in alphabetical order.
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Add additional load paths for your own custom dirs
    config.autoload_paths << (Rails.root + "lib/gitorious")
    config.autoload_paths << (Rails.root + "app")

    # Avoid class cache errors like "A copy of Gitorious::XYZ has been removed
    # from the module tree but is still active!"
    config.autoload_once_paths << (Rails.root + "lib/gitorious")

    # Force all environments to use the same logger level
    # (by default production uses :info, the others :debug)
    # config.log_level = :debug

    # Make Time.zone default to the specified zone, and make Active Record store time values
    # in the database in UTC, and return them converted to the specified local zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Comment line to use default local time.
    config.time_zone = 'UTC'

    # The internationalization framework can be changed to have another default locale (standard is :en) or more load paths.
    # All files from config/locales/*.rb,yml are added automatically.
    # config.i18n.load_path << Dir[File.join(RAILS_ROOT, 'my', 'locales', '*.{rb,yml}')]
    # config.i18n.default_locale = :de

    # Your secret key for verifying cookie session data integrity.
    # If you change this key, all old sessions will become invalid!
    # Make sure the secret is at least 30 characters and all random,
    # no regular words or you'll be exposed to dictionary attacks.

    # Use the database for sessions instead of the cookie-based default,
    # which shouldn't be used to store highly confidential information
    # (create the session table with "rake db:sessions:create")
    #config.action_controller.session_store = :active_record_store

    # Use SQL instead of Active Record's schema dumper when creating the test database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Activate observers that should always be running
    # Please note that observers generated using script/generate observer need to have an _observer suffix
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Activate observers that should always be running
    config.active_record.observers = [
        :user_observer
    ]

    config.after_initialize do
      OAuth::Consumer.class_eval {
        remove_const(:CA_FILE) if const_defined?(:CA_FILE)
      }

      OAuth::Consumer::CA_FILE = nil
      Gitorious::Plugin::post_load
      Grit::Git.git_binary = GitoriousConfig["git_binary"]
    end

    gts_config = YAML.load_file(Rails.root + "config/gitorious.yml")[Rails.env]

    Gitorious::Application.config.middleware.use(ExceptionNotifier,
                                                 :email_prefix => "[Gitorious] ",
                                                 :sender_address => %{"Exception notifier" <notifier@gitorious>},
                                                 :exception_recipients => gts_config["exception_notification_emails"])
  end
end
