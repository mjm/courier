class CreateTweets < ActiveRecord::Migration[5.2]
  def change
    create_table :tweets do |t|
      t.belongs_to :post, null: false
      t.belongs_to :feed_subscription, null: false
      t.text :body
      t.integer :status, null: false, default: 0
      t.datetime :posted_at
      t.string :posted_tweet_id
      t.timestamps
    end
  end
end
