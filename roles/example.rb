Dir.glob("#{__dir__}/../lib/*.rb").each{|f| require_relative f }

include_recipe "../cookbooks/example/default.rb"
