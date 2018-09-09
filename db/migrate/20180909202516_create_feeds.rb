class CreateFeeds < ActiveRecord::Migration[5.2]
  def change
    create_table :feeds do |t|
      t.string :url, null: false
      t.string :title, null: false, default: ''
      t.string :home_page_url, null: false, default: ''
      t.datetime :refreshed_at
      t.timestamps
    end

    add_index :feeds, :url, unique: true
  end
end
