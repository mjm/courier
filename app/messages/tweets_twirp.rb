# Code generated by protoc-gen-twirp_ruby 1.0.0, DO NOT EDIT.
require 'twirp'
require_relative 'tweets_pb.rb'

class TweetsService < Twirp::Service
  service 'Tweets'
  rpc :GetTweets, GetTweetsRequest, GetTweetsResponse, :ruby_method => :get_tweets
  rpc :CancelTweet, CancelTweetRequest, CancelTweetResponse, :ruby_method => :cancel_tweet
  rpc :UpdateTweet, UpdateTweetRequest, UpdateTweetResponse, :ruby_method => :update_tweet
end

class TweetsClient < Twirp::Client
  client_for TweetsService
end
