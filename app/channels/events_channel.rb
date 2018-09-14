class EventsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "events:#{user_id}"
  end

  def unsubscribed; end

  def self.broadcast_event_to(user, event)
    wrapper = EventMessage.new
    key = event.class.name.underscore
    wrapper.send("#{key}=", event)

    ActionCable.server.broadcast("events:#{user.id}", wrapper.to_json, coder: nil)
  end
end
