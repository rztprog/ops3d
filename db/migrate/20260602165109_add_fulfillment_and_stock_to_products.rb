class AddFulfillmentAndStockToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :fulfillment_mode, :string, null: false, default: "made_to_order"
    add_column :products, :stock_quantity, :integer, null: false, default: 0
  end
end
