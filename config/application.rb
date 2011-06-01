require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Entretenerse
  class Application < Rails::Application
    #config.time_zone = "Buenos Aires"
    config.active_record.schema_format = :sql
    config.i18n.default_locale = :es
    config.secret_token = '4087a2a5d436b17cc908916baf24bd81d1e02674b41c5f25733ab5a4e8d73b9f88ffa3961f1a46827a9bb7626e4f80e1932540cde20cd1f36b02490152cb5f5e'
    config.session_store = {
      :key    => '_sandbox_session',
      :secret => '4087a2a5d436b17cc908916baf24bd81d1e02674b41c5f25733ab5a4e8d73b9f88ffa3961f1a46827a9bb7626e4f80e1932540cde20cd1f36b02490152cb5f5e'
    }
    # Look further for translation files
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
  end
end

