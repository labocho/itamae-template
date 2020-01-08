# foo:
#   bar: !include
#     from: nodes/base.yml
#     keys:
#       - foo
#       - bar
#     override:
#       baz: !replace
#         - foobar
#
# のようにして別の yml からデータを参照できる
# from はプロジェクトルートからの相対パス
# keys を省略した場合はルート
# override は deep_merge するが !replace がついている値は置き換える

require "active_support/core_ext/hash"
require "active_support/core_ext/array"
require "yaml"

module YAML
  class Replace
    attr_reader :value

    def self.expand_replace!(o)
      case o
      when Replace
        expand_replace!(o.value)
      when Hash
        o.each do |k, v|
          o[k] = expand_replace!(v)
        end
        o
      when Array
        o.map! {|e| expand_replace!(e) }
      else
        o
      end
    end

    def initialize(value)
      @value = value
    end
  end
end

YAML.add_domain_type("", "inherit") do |type, options|
  invalid_keys = options.keys - %w(from key override)
  unless invalid_keys.empty?
    raise "Unknown options for !inherit: #{invalid_keys.join(", ")}"
  end

  unless File.exist?(options["from"].to_s)
    raise "File not found for !inherit: #{options["from"].inspect}"
  end

  data = YAML.load_file(options["from"])
  data = data.dig(*options["key"]) if options["key"]
  data.deep_merge!(options["override"]) if options["override"]
  YAML::Replace.expand_replace!(data)
end

YAML.add_domain_type("", "replace") do |type, value|
  YAML::Replace.new(value)
end
