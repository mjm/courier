class AddMediaUrlsToTweets < ActiveRecord::Migration[5.2]
  def change
    add_column :tweets, :media_urls, :string, array: true, default: []
  end
end
