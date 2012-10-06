#!/usr/bin/ruby

$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + '/../')

require 'pp'
require 'rubygems'
require 'optparse'
require 'timeout'
require 'stomp'
require 'json'
require 'logger'
require 'lib/config'
require 'lib/helpers'

TIMEOUT = 10
options = Hash.new

opts = OptionParser.new do |opts|
  opts.version = '0.0.1'
  opts.banner = "Usage #{$0} [options]"

  opts.on('-u', '--uuid UUID', 'UUID of monitored command. Will be pushed back into the queue') do |v|
    options[:uuid] = v.to_s
  end
  opts.on('-t', '--timeout SEC', 'how many SECs to wait until exit with no data pulled from queue') do |v|
    options[:timeout] = v.to_s
  end
  opts.on('-a', '--all', 'pulls *all* messages from queue and sends them back to the queue after timeout or interrupt.') do |v|
    options[:all] = v.to_s
  end
  opts.on('-s', '--stream', 'reads all messages from given queue') do |v|
    options[:stream] = v.to_s
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

if options[:uuid].nil? && options[:all].nil? && options[:stream].nil?
  puts opts
  exit 3
end

uuid      = options[:uuid]
timeout   = options[:timeout].nil? ? TIMEOUT : options[:timeout].to_i
conf      = QueueNotifier::Config.new
queue     = conf.queue
username  = conf.username
password  = conf.password
host      = conf.host
consumer  = Stomp::Connection.new(username, password, host, 6163, true)
msg_cache = Array.new
log       = Logger.new(STDOUT) if options[:stream]

consumer.subscribe(queue)

begin
  Timeout::timeout(timeout) do
    loop do
      if options[:all]
        msg  = consumer.receive
        msg_cache << msg
        pp msg
      elsif options[:stream]
        msg  = consumer.receive
        log.info("received: #{msg.body}")
      else
        msg  = consumer.receive
        body = JSON.parse(msg.body)
        if body['uuid'] == uuid
          consumer.unsubscribe(queue)
          puts "UUID: #{body['uuid']} finished with status: #{body['exitcode']}"
          QueueNotifier.send_back(msg_cache, queue, consumer)
          exit 0
        else
          msg_cache << msg
        end
      end
    end
  end
rescue Timeout::Error
  puts 'Operation timed out'
  QueueNotifier.send_back(msg_cache, queue, consumer)
  exit 4
rescue Interrupt
  puts "\nExiting.."
  QueueNotifier.send_back(msg_cache, queue, consumer)
  exit 5
end
