require 'json'

MessageQueue = Struct.new(:conn).new
MessageQueue.conn = Bunny.new(ENV['CLOUDAMQP_URL'])
MessageQueue.conn.start

def listen_for_messages
  ch = MessageQueue.conn.create_channel
  x = ch.direct('events.posts')
  q = ch.queue('', exclusive: true).bind(x)
  q.subscribe do |_delivery_info, _properties, payload|
    tweet = Courier::PostTweet.decode(payload)
    ActionCable.server.broadcast('posts', JSON.parse(Courier::PostTweet.encode_json(tweet)))
  end
end

listen_for_messages
