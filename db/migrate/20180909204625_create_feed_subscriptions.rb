class CreateFeedSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :feed_subscriptions do |t|
      t.belongs_to :feed, foreign_key: true, null: false
      t.belongs_to :user, foreign_key: true, null: false
      t.boolean :autopost, null: false, default: false
      t.timestamps
    end
  end
end
