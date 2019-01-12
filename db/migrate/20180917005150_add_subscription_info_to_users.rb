class AddSubscriptionInfoToUsers < ActiveRecord::Migration[5.2]
  def change
    change_table :users, bulk: true do
      t.string :email
      t.string :stripe_customer_id
      t.string :stripe_subscription_id
      t.datetime :subscription_expires_at
    end
  end
end
