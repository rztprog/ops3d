class CreateProductCustomFields < ActiveRecord::Migration[8.1]
  def change
    create_table :product_custom_fields do |t|
      t.references :product, null: false, foreign_key: true
      t.string :label, null: false
      t.string :field_type, null: false, default: "text"
      t.boolean :required, null: false, default: false
      t.integer :position, null: false, default: 0
      t.string :placeholder

      t.timestamps
    end
  end
end
