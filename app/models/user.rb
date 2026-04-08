class User < ApplicationRecord
  has_many :orders, dependent: :nullify
  has_one :cart, dependent: :destroy

  validates :email, presence: true, uniqueness: true

  # Si tu utilises has_secure_password :
  # has_secure_password
end
