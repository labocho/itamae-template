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

namespace :cert do
  NODES.each do |node, config|
    namespace "export" do
      desc "export cert"
      task node do
        user = config["user"] || "itamae"
        dest = "#{user}@#{config["hostname"]}"
        domains = ENV["DOMAIN"] || raise("DOMAIN required")
        domains.split(",").each do |domain|
          sh "ssh", "-t", dest, "sudo tar zcvf /tmp/#{domain}-certs.tar.gz /etc/letsencrypt/archive/#{domain} /etc/letsencrypt/renewal/#{domain}.conf /etc/letsencrypt/accounts"
          sh "scp", "#{dest}:/tmp/#{domain}-certs.tar.gz", "."
          sh "ssh", "-t", dest, "sudo rm /tmp/#{domain}-certs.tar.gz"
        end
      end
    end

    namespace "import" do
      desc "import cert"
      task node do
        require "shellwords"

        user = config["user"] || "itamae"
        dest = "#{user}@#{config["hostname"]}"
        sh "ssh", "-t", dest, "sudo yum install -y tar"

        domains = ENV["DOMAIN"] || raise("DOMAIN required")
        domains.split(",").each do |domain|
          sh "ssh",  dest, "test ! -e /etc/letsencrypt/archive/#{domain}"
          sh "scp", "#{domain}-certs.tar.gz", "#{dest}:/home/itamae"
          sh "ssh", "-t", dest, "sudo sh -c 'cd / && tar zxvf /home/itamae/#{domain}-certs.tar.gz'"
          sh "ssh", "-t", dest, "sudo mkdir -p /etc/letsencrypt/live/#{domain}"
          sh "ssh", "-t", dest, "sudo chmod 750 /etc/letsencrypt/archive"
          sh "ssh", "-t", dest, "sudo chmod 750 /etc/letsencrypt/live"
          sh "ssh", "-t", dest, "sudo chmod 750 /etc/letsencrypt/accounts"

          %w(cert chain fullchain privkey).each do |f|
            # 最新の pem を探して ln する
            # 単純な sort でなく sed とか使ってるのは cert10.pem があるときに cert9.pem が選択されてしまうのを回避するため
            link = "ls /etc/letsencrypt/archive/#{domain}/#{f}* | " + [
              ["sed", "-e", "s/\\([0-9]*\\)\\.pem/\\0\\t\\1/"],
              %w(sort -n -k 2),
              ["awk", "{ print $1 }"],
              %w(tail -n 1),
              ["xargs", "-ISRC", "ln", "-sf", "SRC", "/etc/letsencrypt/live/#{domain}/#{f}.pem"]
            ].map(&:shelljoin).join(" | ")
            sh "ssh", "-t", dest, "sudo bash -c #{link.shellescape}"
          end

          sh "ssh", "-t", dest, "sudo rm /home/itamae/#{domain}-certs.tar.gz"
        end
      end
    end
  end
end
