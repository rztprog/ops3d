class PromoCode < ApplicationRecord
  TYPES = %w[fixed percent free_shipping]

  validates :code, presence: true, uniqueness: true
  validates :discount_type, inclusion: { in: TYPES }

  validates :value,
    numericality: { greater_than_or_equal_to: 0 },
    allow_nil: true

  validates :value,
    presence: true,
    unless: -> { discount_type == "free_shipping" }

  scope :active, -> { where(active: true) }


  def expired?
    expires_at.present? && expires_at.past?
  end

  def usable?
    return false unless active?
    return false if expired?

    return true if max_uses.blank?

    uses_count < max_uses
  end
end
