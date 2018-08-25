class PostsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "posts:#{user_id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
