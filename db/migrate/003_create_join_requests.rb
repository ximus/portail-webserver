class CreateJoinRequests < ActiveRecord::Migration
  def change
    create_table :join_requests do |t|
      t.references :user
      t.string     :provider_id

      t.timestamp :canceled_at
      t.integer   :canceled_by

      t.timestamp :created_at
    end
  end
end