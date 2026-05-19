class PromoCode < ApplicationRecord
  before_validation :normalize_code

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :discount_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :active, inclusion: { in: [ true, false ] }

  scope :active, -> { where(active: true) }

  def expired?
    expires_at.present? && expires_at.past?
  end

  def usable?
    return false unless active?
    return false if expired?

    return true if max_uses.blank?

    uses_count.to_i < max_uses
  end

  def free_shipping?
    code == "FREE"
  end

  def compute_discount(subtotal_cents)
    return 0 unless usable?

    if free_shipping?
      Ops3dSetting.first&.shipping_price_cents.to_i
    else
      value.to_i
    end
  end

  private

  def normalize_code
    self.code = code.to_s.strip.upcase
  end
end
