# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: feeds.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "GetFeedsRequest" do
  end
  add_message "GetFeedsResponse" do
    repeated :feeds, :message, 1, "FeedMessage"
  end
  add_message "RegisterFeedRequest" do
    optional :url, :string, 1
  end
  add_message "RegisterFeedResponse" do
    optional :feed, :message, 1, "FeedMessage"
  end
  add_message "RefreshFeedRequest" do
    optional :id, :int64, 1
  end
  add_message "RefreshFeedResponse" do
  end
  add_message "FeedMessage" do
    optional :id, :int64, 1
    optional :url, :string, 2
    optional :created_at, :string, 3
    optional :updated_at, :string, 4
    optional :refreshed_at, :string, 5
    optional :title, :string, 6
    optional :home_page_url, :string, 7
    optional :settings, :message, 8, "FeedSettingsMessage"
  end
  add_message "FeedSettingsMessage" do
    optional :autopost, :bool, 1
  end
end

GetFeedsRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("GetFeedsRequest").msgclass
GetFeedsResponse = Google::Protobuf::DescriptorPool.generated_pool.lookup("GetFeedsResponse").msgclass
RegisterFeedRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("RegisterFeedRequest").msgclass
RegisterFeedResponse = Google::Protobuf::DescriptorPool.generated_pool.lookup("RegisterFeedResponse").msgclass
RefreshFeedRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("RefreshFeedRequest").msgclass
RefreshFeedResponse = Google::Protobuf::DescriptorPool.generated_pool.lookup("RefreshFeedResponse").msgclass
FeedMessage = Google::Protobuf::DescriptorPool.generated_pool.lookup("FeedMessage").msgclass
FeedSettingsMessage = Google::Protobuf::DescriptorPool.generated_pool.lookup("FeedSettingsMessage").msgclass