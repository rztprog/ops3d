class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true

      t.string :status, null: false

      t.integer :subtotal_price_cents, null: false
      t.string :shipping_mode, null: false
      t.integer :shipping_price_cents, null: false
      t.integer :total_price_cents, null: false

      # Snapshot client
      t.string :email, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :address_line, null: false
      t.string :city, null: false
      t.string :postal_code, null: false
      t.string :country, null: false

      t.timestamps
    end
  end
end
