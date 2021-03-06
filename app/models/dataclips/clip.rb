require "liquid"

module DataclipsFilters
  def quote_literals(input)
    input.map do |item|
      item.is_a?(String) ? "'#{item}'" : item
    end
  end
end

Liquid::Template.register_filter(DataclipsFilters)

module Dataclips
  class Clip
    attr_accessor :clip_id, :template, :params, :schema, :name

    def initialize(clip_id, schema = nil)
      @clip_id   = clip_id
      @template  = load_template

      load_config(schema)
    end

    def per_page
      @per_page
    end

    def load_config(schema)
      config_file = Dir.chdir(Dataclips::Engine.config.path) do
        schema.present? ? File.read("#{clip_id}.#{schema}.yml") : File.read("#{clip_id}.yml") 
      end

      config_yaml = YAML.load(config_file)

      @schema = (config_yaml["schema"] || {}).reduce({}) do |schema, (attribute, options)|
        schema[attribute] = options.reverse_merge({"grid" => true, "filter" => true})
        schema
      end

      @per_page = config_yaml["per_page"] || 1000
      @name     = config_yaml["name"]
    end

    def load_template
      Dir.chdir(Dataclips::Engine.config.path) do
        Liquid::Template.parse File.read("#{clip_id}.sql")
      end
    end

    def query(params = {})
      template.render(params.with_indifferent_access)
    end
  end
end
