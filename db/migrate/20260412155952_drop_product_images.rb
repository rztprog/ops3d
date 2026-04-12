class DropProductImages < ActiveRecord::Migration[8.1]
  def change
    drop_table :product_images
  end
end
