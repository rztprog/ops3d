class Cart < ApplicationRecord
  belongs_to :user, optional: true

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validate :user_or_guest_token_present

  private

  def user_or_guest_token_present
    return if user_id.present? || guest_token.present?

    errors.add(:base, "Le panier doit appartenir à un utilisateur ou avoir un guest_token")
  end
end
