class CreateBlackllists < ActiveRecord::Migration
  def change
    create_table :blackllists do |t|
      t.integer :user_id
      t.boolean :status

      t.timestamps null: false
    end
  end
end
