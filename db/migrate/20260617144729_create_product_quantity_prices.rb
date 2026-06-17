class CreateProductQuantityPrices < ActiveRecord::Migration[8.1]
  def change
    create_table :product_quantity_prices do |t|
      t.references :product, null: false, foreign_key: true
      t.integer :min_quantity
      t.integer :unit_price_cents

      t.timestamps
    end
  end
end
