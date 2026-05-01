class CreateProductCustomFields < ActiveRecord::Migration[8.1]
  def change
    create_table :product_custom_fields do |t|
      t.references :product, null: false, foreign_key: true
      t.string :label
      t.string :field_type
      t.boolean :required
      t.integer :position
      t.string :placeholder

      t.timestamps
    end
  end
end
