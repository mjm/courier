class AddCachingToFeeds < ActiveRecord::Migration[5.2]
  def change
    change_table :feeds, bulk: true do |t|
      t.string :etag
      t.string :last_modified_at
    end
  end
end
