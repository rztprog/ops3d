class CreateOps3dSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :ops3d_settings do |t|
      t.string :shipping_mode, null: false
      t.integer :shipping_price_cents, null: false, default: 0

      t.timestamps
    end
  end
end
