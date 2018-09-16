class AddPostJobIdToTweets < ActiveRecord::Migration[5.2]
  def change
    add_column :tweets, :post_job_id, :string
  end
end
