class Ops3dSetting < ApplicationRecord
  SHIPPING_MODES = %w[free flat_rate].freeze

  validates :shipping_mode, presence: true, inclusion: { in: SHIPPING_MODES }
  validates :shipping_price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :flat_rate_requires_positive_price

  def shipping_price_euros
    shipping_price_cents.to_f / 100
  end

  private

  def flat_rate_requires_positive_price
    return unless shipping_mode == "flat_rate"
    return if shipping_price_cents.to_i.positive?

    errors.add(:shipping_price_cents, "doit être supérieur à 0 pour une livraison forfaitaire")
  end
end
