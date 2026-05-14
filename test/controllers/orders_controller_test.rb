require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email: "jeandupont@mailexample.com",
      password: "password123",
      first_name: "Jean",
      last_name: "Dupont",
      confirmed_at: Time.current
    )

    @order = Order.create!(
      user: @user,
      status: "paid",
      email: @user.email,
      first_name: "Jean",
      last_name: "Dupont",
      address_line: "1 rue de Test",
      city: "Paris",
      postal_code: "75001",
      country: "France",
      shipping_mode: "flat_rate",
      subtotal_price_cents: 2_000,
      shipping_price_cents: 500,
      total_price_cents: 2_500
    )

    sign_in @user
  end

  test "checkout redirects when order is already paid" do
    post checkout_order_path(locale: :fr, id: @order.id)

    assert_redirected_to order_path(locale: :fr, id: @order.id)
    assert_equal "Cette commande ne peut plus être payée.", flash[:alert]
  end

  test "checkout includes shipping line item when shipping price is present" do
    @order.update!(
      status: "pending",
      shipping_price_cents: 500,
      total_price_cents: 2_500
    )

    @order.order_items.create!(
      product_name: "RIO 3D",
      quantity: 1,
      unit_price_cents: 2_000
    )

    fake_session = OpenStruct.new(
      id: "cs_test_123",
      url: "https://checkout.stripe.com/test"
    )

    captured_payload = nil

    Stripe::Checkout::Session.singleton_class.define_method(:create) do |payload|
      captured_payload = payload
      fake_session
    end

    post checkout_order_path(locale: :fr, id: @order.id)

    assert_redirected_to "https://checkout.stripe.com/test"

    assert_equal 2, captured_payload[:line_items].size

    shipping_item = captured_payload[:line_items].find do |item|
      item[:price_data][:product_data][:name] == "Frais de livraison"
    end

    assert shipping_item
    assert_equal 500, shipping_item[:price_data][:unit_amount]
    assert_equal 1, shipping_item[:quantity]
  end
end
