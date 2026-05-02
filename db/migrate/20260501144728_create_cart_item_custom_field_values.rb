class CreateCartItemCustomFieldValues < ActiveRecord::Migration[8.1]
  def change
    create_table :cart_item_custom_field_values do |t|
      t.references :cart_item, null: false, foreign_key: true
      t.references :product_custom_field, null: false, foreign_key: true
      t.text :value

      t.timestamps
    end

    add_index :cart_item_custom_field_values,
      [ :cart_item_id, :product_custom_field_id ],
      unique: true,
      name: "index_cart_item_custom_values_unique"
  end
end
