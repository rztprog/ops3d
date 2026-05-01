class AddCustomizationsToOrderItems < ActiveRecord::Migration[8.1]
  def change
    add_column :order_items, :customizations, :jsonb
  end
end
