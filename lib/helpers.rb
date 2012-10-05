module QueueNotifier
  def self.send_back(messages, queue, stomp)
    messages.each do |msg|
      stomp.unsubscribe(queue)
      stomp.unreceive(msg, { :dead_letter_queue => queue })
    end
  end
end
