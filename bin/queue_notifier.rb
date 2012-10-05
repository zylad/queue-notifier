#!/usr/bin/ruby

$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + '/../')

require 'pp'
require 'rubygems'
require 'stomp'
require 'json'
require 'optparse'
require 'lib/config'

options = Hash.new

opts = OptionParser.new do |opts|
  opts.version = '0.0.1'
  opts.banner = "Usage #{$0} [options]"
  opts.on('-c', '--command COMMAND', 'Specify command to be monitored') do |v|
    options[:command] = v.to_s
  end
  opts.on('-u', '--uuid UUID', 'UUID of monitored command. Will be pushed back into the queue') do |v|
    options[:uuid] = v.to_s
  end
end

begin
  opts.parse!
rescue OptionParser::InvalidOption
  puts opts
  exit 1
rescue OptionParser::MissingArgument
  puts opts
  exit 2
end

unless (options[:command])
  puts opts
  exit 3
end

command   = options[:command]
conf      = QueueNotifier::Config.new
queue     = conf.queue
username  = conf.username
password  = conf.password
host      = conf.host
provider  = Stomp::Client.new(username, password, host, 6163, true)
uuid      = options[:uuid].nil? ? `uuidgen`.strip : options[:uuid]

begin
  cmdrun   = IO.popen(command)
  exitcode = $?.to_i
  cmdrun.close
  json = JSON.generate({ :uuid => uuid, :exitcode => exitcode  })
  puts "Sending UUID: #{uuid}"
  provider.publish(queue, json)
rescue => e
  raise "Error: #{e}"
end
