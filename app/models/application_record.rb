class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def format_timestamp(time)
    time.present? ? time.getutc.iso8601 : ''
  end
end
