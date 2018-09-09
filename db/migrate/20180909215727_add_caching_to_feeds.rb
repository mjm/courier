class AddCachingToFeeds < ActiveRecord::Migration[5.2]
  def change
    add_column :feeds, :etag, :string
    add_column :feeds, :last_modified_at, :string
  end
end
