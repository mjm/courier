class AddSubscriptionRenewsAtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :subscription_renews_at, :datetime
  end
end
