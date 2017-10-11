require 'serverspec'
require 'net/ssh'
require 'tempfile'
require "shellwords"
require "yaml"

set :backend, :ssh

def vagrant(*args)
  Dir.chdir("#{__dir__}/../vagrant") do
    `vagrant #{args.shelljoin}`
  end
end

if ENV['ASK_SUDO_PASSWORD']
  begin
    require 'highline/import'
  rescue LoadError
    fail "highline is not available. Try installing it."
  end
  set :sudo_password, ask("Enter sudo password: ") { |q| q.echo = false }
else
  set :sudo_password, ENV['SUDO_PASSWORD']
end

host = ENV['TARGET_HOST']
nodes = YAML.load_file("#{__dir__}/../nodes.yml")
node = nodes[host]

if node["vagrant"]
  vagrant("up", node["vagrant"])
end

config = Tempfile.new('', Dir.tmpdir)
config.write(<<-SSH_CONFIG
Host #{host}
User itamae
HostName #{node["hostname"]}
SSH_CONFIG
)
config.close

options = Net::SSH::Config.for(host, [config.path])

options[:user] ||= Etc.getlogin

set :host,        options[:host_name] || host
set :ssh_options, options

# Disable sudo
# set :disable_sudo, true


# Set environment variables
# set :env, :LANG => 'C', :LC_MESSAGES => 'C'

# Set PATH
# set :path, '/sbin:/usr/local/sbin:$PATH'
