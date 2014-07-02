class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.references :user
      t.string :provider_uid, null: false
      t.string :provider,     null: false
      t.uuid   :slug, null: false

      t.timestamps

      t.index :slug, unique: true
      t.index [:provider, :provider_uid], unique: true
    end
  end
end