class AddStatusToFeeds < ActiveRecord::Migration[5.2]
  def change
    change_table :feeds, bulk: true do
      t.integer :status, null: false, default: 0
      t.string :refresh_message
    end
  end
end
