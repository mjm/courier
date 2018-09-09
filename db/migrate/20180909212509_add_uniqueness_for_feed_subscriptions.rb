class AddUniquenessForFeedSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_index :feed_subscriptions, %i[feed_id user_id], unique: true
  end
end
