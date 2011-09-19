class CreateForums < ActiveRecord::Migration
  def change
    create_table :forums do |t|
      t.string :name
      t.integer :vb_id
      t.datetime :last_updated
      t.references :site

      t.timestamps
    end
    add_index :forums, :site_id
  end
end
