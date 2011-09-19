class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :text
      t.datetime :posted_at
      t.string :posted_by
      t.references :topic

      t.timestamps
    end
    add_index :messages, :topic_id
  end
end
