class AddSubscriptionStepToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :subscription_step, :integer
  end
end
