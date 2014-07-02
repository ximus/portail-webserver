class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email

      t.string :image_url
      t.integer :vetted_by

      t.timestamps

      t.index :vetted_by
    end
  end
end