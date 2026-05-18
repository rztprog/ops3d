class PromoCode < ApplicationRecord
  before_validation :normalize_code

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :discount_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :active, inclusion: { in: [ true, false ] }

  scope :active, -> { where(active: true) }

  private

  def normalize_code
    self.code = code.to_s.strip.upcase
  end
end
