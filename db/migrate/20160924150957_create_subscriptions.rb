class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.string :campaign_name
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
