class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :name
      t.string :vb_id
      t.datetime :last_updated
      t.references :forum

      t.timestamps
    end
    add_index :topics, :forum_id
  end
end
