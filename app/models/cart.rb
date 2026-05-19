class Cart < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :promo_code, optional: true

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validate :user_or_guest_token_present

  def subtotal_cents
    cart_items.includes(:product).sum do |item|
      item.quantity * item.product.price_cents
    end
  end

  def shipping_cents
    settings = Ops3dSetting.first

    return 0 unless settings

    settings.shipping_mode == "flat_rate" ? settings.shipping_price_cents : 0
  end

  def discount_cents
    return 0 unless promo_code&.usable?

    [ promo_code.discount_cents, subtotal_cents ].min
  end

  def total_cents
    subtotal_cents + shipping_cents - discount_cents
  end

  private

  def user_or_guest_token_present
    return if user_id.present? || guest_token.present?

    errors.add(:base, "Le panier doit appartenir à un utilisateur ou avoir un guest_token")
  end
end
