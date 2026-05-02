class RemoveUniqueIndexFromCartItems < ActiveRecord::Migration[8.1]
  def change
    remove_index :cart_items, column: [ :cart_id, :product_id ]
    add_index :cart_items, [ :cart_id, :product_id ]
  end
end
