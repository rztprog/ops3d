class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  # Objet avec des fields en plus relié au product-custom-fields
  has_many :cart_item_custom_field_values, dependent: :destroy
  has_many :product_custom_fields, through: :cart_item_custom_field_values
end
