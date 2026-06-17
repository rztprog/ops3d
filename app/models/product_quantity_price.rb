class ProductQuantityPrice < ApplicationRecord
  belongs_to :product

  validates :min_quantity,
    presence: true,
    numericality: { only_integer: true, greater_than: 1 }

  validates :unit_price_cents,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
