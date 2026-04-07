class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.integer :price_cents, null: false
      t.references :category, null: false, foreign_key: true
      t.boolean :published, default: false, null: false
      t.boolean :available, default: true, null: false

      t.timestamps
    end
  end
end
