require "test_helper"

class StripeWebhooksControllerTest < ActionDispatch::IntegrationTest
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
      status: "pending",
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

    @session = OpenStruct.new(
      id: "cs_test_123",
      payment_intent: "pi_test_123",
      metadata: OpenStruct.new(
        order_id: @order.id.to_s,
        user_id: @user.id.to_s
      )
    )
  end

  test "fulfill_order marks order as paid and sends emails once" do
    assert_enqueued_emails 2 do
      StripeWebhooksController.new.send(:fulfill_order, @session)
    end

    @order.reload

    assert_equal "paid", @order.status
    assert_equal "cs_test_123", @order.stripe_checkout_session_id
    assert_equal "pi_test_123", @order.stripe_payment_intent_id
  end

  test "fulfill_order is idempotent and does not send emails twice" do
    StripeWebhooksController.new.send(:fulfill_order, @session)
    @order.reload

    assert_equal "paid", @order.status

    assert_enqueued_emails 0 do
      StripeWebhooksController.new.send(:fulfill_order, @session)
    end
  end

  test "webhook returns bad request with invalid signature" do
    original_secret = ENV["STRIPE_WEBHOOK_SECRET"]
    ENV["STRIPE_WEBHOOK_SECRET"] = "whsec_test_secret"

    post "/stripe_webhooks",
        params: "{}",
        headers: {
          "HTTP_STRIPE_SIGNATURE" => "invalid"
        },
        as: :json

    assert_response :bad_request
  ensure
    ENV["STRIPE_WEBHOOK_SECRET"] = original_secret
  end
end
