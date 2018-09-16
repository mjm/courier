class AddWillPostAtToTweets < ActiveRecord::Migration[5.2]
  def change
    add_column :tweets, :will_post_at, :datetime
  end
end
