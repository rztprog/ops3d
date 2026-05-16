class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable,
          :confirmable

  has_many :orders, dependent: :nullify
  has_one :cart, dependent: :destroy

  validates :email, presence: true, uniqueness: true

  # Order without login
  after_confirmation :attach_previous_orders

  def attach_previous_orders
    Order.where(
      email: email,
      user_id: nil
    ).update_all(user_id: id)
  end
end
