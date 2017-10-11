require "yaml"
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

        sh "bin/itamae", "ssh", "--node-json=#{node_file}", "--host=#{config["hostname"]}", "--user=chef", *config["recipes"]
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

        sh "bin/itamae", "ssh", "--dry-run", "--node-json=#{node_file}", "--host=#{config["hostname"]}", "--user=chef", *config["recipes"]
      end
    end
  end
end

namespace :ssh do
  NODES.each do |node, config|
    desc "`ssh` for #{node}"
    task node do
      exec "ssh", "chef@#{config["hostname"]}"
    end
  end
end

file "encryption_key" do
  sh "openssl rand -base64 512 | tr -d '\\r\\n' > encryption_key"
end
