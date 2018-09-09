class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.belongs_to :feed, null: false
      t.string :item_id, null: false
      t.index %i[feed_id item_id], unique: true

      t.text :content_html, null: false, default: ''
      t.text :content_text, null: false, default: ''
      t.string :title, null: false, default: ''
      t.string :url, null: false, default: ''

      t.datetime :published_at
      t.datetime :modified_at
      t.timestamps
    end
  end
end
