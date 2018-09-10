# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: tweets.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "GetTweetsRequest" do
  end
  add_message "GetTweetsResponse" do
    repeated :tweets, :message, 1, "TweetMessage"
  end
  add_message "CancelTweetRequest" do
    optional :id, :int64, 1
  end
  add_message "CancelTweetResponse" do
    optional :tweet, :message, 1, "TweetMessage"
  end
  add_message "TweetMessage" do
    optional :id, :int64, 1
    optional :body, :string, 2
    optional :post, :message, 3, "PostMessage"
    optional :status, :enum, 4, "TweetMessage.Status"
    optional :posted_at, :string, 5
    optional :posted_tweet_id, :string, 6
  end
  add_enum "TweetMessage.Status" do
    value :DRAFT, 0
    value :CANCELED, 1
    value :POSTED, 2
  end
  add_message "PostMessage" do
    optional :id, :int64, 1
    optional :url, :string, 2
    optional :published_at, :string, 3
    optional :modified_at, :string, 4
  end
end

GetTweetsRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("GetTweetsRequest").msgclass
GetTweetsResponse = Google::Protobuf::DescriptorPool.generated_pool.lookup("GetTweetsResponse").msgclass
CancelTweetRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("CancelTweetRequest").msgclass
CancelTweetResponse = Google::Protobuf::DescriptorPool.generated_pool.lookup("CancelTweetResponse").msgclass
TweetMessage = Google::Protobuf::DescriptorPool.generated_pool.lookup("TweetMessage").msgclass
TweetMessage::Status = Google::Protobuf::DescriptorPool.generated_pool.lookup("TweetMessage.Status").enummodule
PostMessage = Google::Protobuf::DescriptorPool.generated_pool.lookup("PostMessage").msgclass
