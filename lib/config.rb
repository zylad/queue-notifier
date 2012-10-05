require 'rubygems'
require 'parseconfig'

module QueueNotifier
  class Config

    def initialize
      c = File.expand_path(File.dirname(__FILE__) + '/../etc/queue_notifier.conf')
      @conf ||= ParseConfig.new(c)
    end
  
    def username
      user = @conf.params['stomp']['username']
      user.chomp
    end
  
    def password
      pass = @conf.params['stomp']['password']
      pass.chomp
    end
  
    def queue
      queue = @conf.params['stomp']['queue']
      queue.chomp
    end
  
    def host
      host = @conf.params['stomp']['host']
      host.chomp
    end

  end
end
