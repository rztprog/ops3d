class Cart < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :promo_code, optional: true

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validate :user_or_guest_token_present

  def subtotal_cents
    cart_items.includes(:product).sum do |item|
      item.quantity * item.product.unit_price_cents_for(item.quantity)
    end
  end

  def shipping_cents
    settings = Ops3dSetting.first
    return 0 unless settings

    return 0 if subtotal_cents >= settings.free_shipping_threshold_cents.to_i

    settings.shipping_mode == "flat_rate" ? settings.shipping_price_cents : 0
  end

  def discount_cents
    return 0 if cart_items.empty?
    return 0 unless promo_code&.usable?

    [ promo_code.discount_cents, subtotal_cents ].min
  end

  def total_cents
    subtotal_cents + shipping_cents - discount_cents
  end

  def free_shipping_threshold_cents
    Ops3dSetting.first&.free_shipping_threshold_cents.to_i
  end

  def amount_until_free_shipping_cents
    [ free_shipping_threshold_cents - subtotal_cents, 0 ].max
  end

  def free_shipping_progress_percent
    return 100 if free_shipping_threshold_cents.zero?

    [ (subtotal_cents.to_f / free_shipping_threshold_cents * 100).round, 100 ].min
  end

  def free_shipping_unlocked?
    subtotal_cents >= free_shipping_threshold_cents
  end

  private

  def user_or_guest_token_present
    return if user_id.present? || guest_token.present?

    errors.add(:base, "Le panier doit appartenir à un utilisateur ou avoir un guest_token")
  end
end
