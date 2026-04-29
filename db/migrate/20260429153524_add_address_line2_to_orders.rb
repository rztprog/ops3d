class AddAddressLine2ToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :address_line2, :string
  end
end
