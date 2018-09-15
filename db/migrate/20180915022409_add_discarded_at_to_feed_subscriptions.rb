class AddDiscardedAtToFeedSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :feed_subscriptions, :discarded_at, :datetime
    add_index :feed_subscriptions, :discarded_at
  end
end
