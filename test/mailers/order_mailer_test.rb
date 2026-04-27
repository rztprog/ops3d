require "test_helper"

class OrderMailerTest < ActionMailer::TestCase
  test "paid_confirmation" do
    mail = OrderMailer.paid_confirmation
    assert_equal "Paid confirmation", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
