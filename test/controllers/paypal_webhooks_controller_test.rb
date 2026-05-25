require "test_helper"

class PaypalWebhooksControllerTest < ActionDispatch::IntegrationTest
 setup do
    @user = User.create!(
      email: "client-paypal@example.com",
      password: "password123",
      first_name: "Jean",
      last_name: "Doe",
      confirmed_at: Time.current
    )

    @order = Order.create!(
      user: @user,
      status: "pending",
      email: @user.email,
      first_name: "Jean",
      last_name: "Doe",
      address_line: "1 rue Test",
      city: "Paris",
      postal_code: "75001",
      country: "France",
      shipping_mode: "flat_rate",
      subtotal_price_cents: 2_000,
      shipping_price_cents: 500,
      discount_cents: 0,
      total_price_cents: 2_500,
      payment_provider: "paypal",
      paypal_order_id: "PAYPAL_ORDER_123"
    )

    @event = {
      "resource" => {
        "id" => "CAPTURE_123",
        "supplementary_data" => {
          "related_ids" => {
            "order_id" => "PAYPAL_ORDER_123"
          }
        }
      }
    }
  end

  test "capture completed marks order as paid and sends emails once" do
    assert_enqueued_emails 2 do
      PaypalWebhooksController.new.send(:handle_capture_completed, @event)
    end

    @order.reload

    assert_equal "paid", @order.status
    assert_equal "paypal", @order.payment_provider
    assert_equal "CAPTURE_123", @order.paypal_capture_id
  end

  test "capture completed is idempotent and does not send emails twice" do
    PaypalWebhooksController.new.send(:handle_capture_completed, @event)

    assert_enqueued_emails 0 do
      PaypalWebhooksController.new.send(:handle_capture_completed, @event)
    end

    @order.reload

    assert_equal "paid", @order.status
    assert_equal "CAPTURE_123", @order.paypal_capture_id
  end
end
