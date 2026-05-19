class AddPromoSnapshotToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :promo_code, :string
    add_column :orders, :discount_cents, :integer, null: false, default: 0
  end
end
