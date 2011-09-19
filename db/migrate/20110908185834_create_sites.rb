class CreateSites < ActiveRecord::Migration

  def change
    create_table :sites do |t|
      t.string :name
      t.string :url
      t.datetime :last_updated
      t.string :username
      t.string :password

      t.timestamps
    end
  end

end
