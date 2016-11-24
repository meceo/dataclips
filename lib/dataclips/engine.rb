module Dataclips
  class Engine < ::Rails::Engine
    isolate_namespace Dataclips

    config.before_configuration do
      config.dictionaries = {}
      config.salt         = ENV['DATACLIPS_TOKENIZER'] || Rails.application.secrets.secret_key_base
      config.path         = Rails.root.join('app/dataclips').to_s
      config.watchable_files.concat Dir.glob("#{config.path}/**/*.sql")
    end
  end
end
