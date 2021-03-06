module FeedType
  extend ActiveSupport::Concern

  class_methods do
    def register(type, priority, extra_types = [])
      define_method(:mime_type) do
        type
      end

      all_types = [type] + extra_types
      types_pattern = all_types.map { |t| Regexp.quote(t) }.join('|')
      type_regex = /^(#{types_pattern})/

      define_method(:mime_type_regex) do
        type_regex
      end
      define_method(:priority) do
        priority
      end

      FeedType.all[type] = new
      extra_types.each do |t|
        FeedType.all[t] = new
      end
    end
  end

  def self.all
    @all ||= {}
  end

  def self.prioritized
    all.values.sort_by(&:priority)
  end

  def self.by_mime_type(type)
    all.values.detect { |t| t.mime_type_regex =~ type }
  end

  # It's important that we normalize URLs because we need to be able to
  # later be able to find the feed that goes with a home page URL.
  def normalize_url(url)
    Addressable::URI.parse(url)&.normalize&.to_s
  end
end

require 'json_feed'
require 'atom_feed'
require 'rss_feed'
