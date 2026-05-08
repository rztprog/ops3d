require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email: "jeandupont@mailexample.com",
      password: "password123",
      first_name: "Jean",
      last_name: "Dupont"
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
end
