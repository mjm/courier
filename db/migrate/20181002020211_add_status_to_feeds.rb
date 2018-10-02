class AddStatusToFeeds < ActiveRecord::Migration[5.2]
  def change
    add_column :feeds, :status, :integer, null: false, default: 0
    add_column :feeds, :refresh_message, :string
  end
end
