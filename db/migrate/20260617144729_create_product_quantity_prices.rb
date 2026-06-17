class CreateProductQuantityPrices < ActiveRecord::Migration[8.1]
  def change
    create_table :product_quantity_prices do |t|
      t.references :product, null: false, foreign_key: true
      t.integer :min_quantity, null: false
      t.integer :unit_price_cents, null: false

      t.timestamps
    end

    add_index :product_quantity_prices,
      [ :product_id, :min_quantity ],
      unique: true
  end
end
