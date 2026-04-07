class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email, null: false
      t.string :encrypted_password, null: false
      t.boolean :admin, default: false, null: false

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
