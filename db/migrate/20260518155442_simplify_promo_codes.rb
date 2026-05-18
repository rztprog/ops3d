class SimplifyPromoCodes < ActiveRecord::Migration[8.1]
  def change
    remove_column :promo_codes, :discount_type, :string
    remove_column :promo_codes, :value, :integer
    remove_column :promo_codes, :expires_at, :datetime
    remove_column :promo_codes, :max_uses, :integer
    remove_column :promo_codes, :uses_count, :integer

    change_column_null :promo_codes, :code, false
    change_column_null :promo_codes, :active, false
    change_column_default :promo_codes, :active, from: nil, to: true

    add_column :promo_codes, :discount_cents, :integer, null: false, default: 0
    add_index :promo_codes, :code, unique: true
  end
end
