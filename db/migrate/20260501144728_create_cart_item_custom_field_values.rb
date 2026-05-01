class CreateCartItemCustomFieldValues < ActiveRecord::Migration[8.1]
  def change
    create_table :cart_item_custom_field_values do |t|
      t.references :cart_item, null: false, foreign_key: true
      t.references :product_custom_field, null: false, foreign_key: true
      t.text :value

      t.timestamps
    end
  end
end
