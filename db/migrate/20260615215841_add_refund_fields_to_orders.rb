class AddRefundFieldsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :refund_reason, :text
    add_column :orders, :refunded_at, :datetime
  end
end
