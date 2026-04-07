class CreateCarts < ActiveRecord::Migration[8.1]
  def change
    create_table :carts do |t|
      t.references :user, foreign_key: true
      t.string :guest_token

      t.timestamps
    end

    add_index :carts, :guest_token
  end
end
