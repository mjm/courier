module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :user_id

    attr_reader :user_id

    def connect
      self.user_id = cookies.encrypted[:user_id]
    end
  end
end
