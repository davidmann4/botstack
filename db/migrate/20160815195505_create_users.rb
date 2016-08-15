class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :fb_id, :limit => 8
      t.datetime :last_message_received
      t.integer :state_machine

      t.timestamps null: false
    end
  end
end
