class AddFreeShippingThresholdToOps3dSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :ops3d_settings, :free_shipping_threshold_cents, :integer, null: false, default: 2500
  end
end
