# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: flags.proto

require 'google/protobuf'

require 'feeds_pb'
require 'tweets_pb'
require 'users_pb'
Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "IndexFlags" do
    repeated :tweets, :message, 1, "TweetMessage"
    optional :user, :message, 2, "UserMessage"
  end
  add_message "FeedsFlags" do
    repeated :feeds, :message, 1, "FeedMessage"
    optional :user, :message, 2, "UserMessage"
  end
  add_message "AccountFlags" do
    optional :stripe_key, :string, 1
    optional :user, :message, 2, "UserMessage"
  end
end

IndexFlags = Google::Protobuf::DescriptorPool.generated_pool.lookup("IndexFlags").msgclass
FeedsFlags = Google::Protobuf::DescriptorPool.generated_pool.lookup("FeedsFlags").msgclass
AccountFlags = Google::Protobuf::DescriptorPool.generated_pool.lookup("AccountFlags").msgclass