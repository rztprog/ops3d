class Ops3dSetting < ApplicationRecord
  SHIPPING_MODES = %w[free flat_rate].freeze

  validates :shipping_mode, presence: true, inclusion: { in: SHIPPING_MODES }
  validates :shipping_price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
