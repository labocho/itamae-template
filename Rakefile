require_relative "lib/yaml"
require "tmpdir"
require "json"

load "./spec/serverspec.rake"

NODES = YAML.load_file("nodes.yml")

namespace :cook do
  NODES.each do |node, config|
    desc "`itamae ssh` for #{node}"
    task node do
      Dir.mktmpdir do |tmpdir|
        node_file = "#{tmpdir}/node.json"
        File.write(node_file, (config["attributes"] || {}).to_json)
        log_level = ENV["DEBUG"] ? "debug" : "info"

        sh "bin/itamae", "ssh", "--log-level=#{log_level}", "--node-json=#{node_file}", "--host=#{config["hostname"]}", "--user=#{config["user"] || "itamae"}", *config["recipes"]
      end
    end
  end
end

namespace :"dry-run" do
  NODES.each do |node, config|
    desc "`itamae ssh --dry-run` for #{node}"
    task node do
      Dir.mktmpdir do |tmpdir|
        node_file = "#{tmpdir}/node.json"
        File.write(node_file, (config["attributes"] || {}).to_json)

        sh "bin/itamae", "ssh", "--dry-run", "--node-json=#{node_file}", "--host=#{config["hostname"]}", "--user=#{config["user"] || "itamae"}", *config["recipes"]
      end
    end
  end
end

namespace :nodes do
  desc "Print decrypted nodes.yml"
  task :decrypt do
    require_relative "lib/decrypt.rb"
    puts decrypt_attributes(NODES).to_yaml
  end
end

namespace :ssh do
  NODES.each do |node, config|
    desc "`ssh` for #{node}"
    task node do
      exec "ssh", "#{config["user"] || "itamae"}@#{config["hostname"]}"
    end
  end
end

file "encryption_key" do
  sh "openssl rand -base64 512 | tr -d '\\r\\n' > encryption_key"
end
