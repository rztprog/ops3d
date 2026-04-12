# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require "open-uri"

puts "Cleaning database..."
OrderItem.destroy_all
Order.destroy_all
CartItem.destroy_all
Cart.destroy_all
Product.destroy_all
Category.destroy_all
User.destroy_all

puts "Creating settings..."
settings = Ops3dSetting.first_or_initialize
settings.update!(
  shipping_mode: "flat_rate",
  shipping_price_cents: 490
)

puts "Creating admin..."
User.create!(
  email: "admin@ops3d.local",
  password: "password123",
  password_confirmation: "password123",
  first_name: "Admin",
  last_name: "Ops3d",
  admin: true
)

puts "Creating categories..."
fixations = Category.create!(name: "Fixations")
supports = Category.create!(name: "Supports")

puts "Creating products..."

product1 = Product.create!(
  name: "Support caméra",
  description: "Support imprimé 3D robuste",
  price_cents: 2490,
  category: supports,
  published: true,
  available: true
)

file1 = URI.open("https://images.unsplash.com/photo-1589976584421-86fda88fa33a")
product1.images.attach(io: file1, filename: "support_camera.jpg", content_type: "image/jpg")

product2 = Product.create!(
  name: "Fixation murale",
  description: "Fixation légère et résistante",
  price_cents: 1490,
  category: fixations,
  published: true,
  available: true
)

file2 = URI.open("https://images.unsplash.com/photo-1611004061856-ccc3cbe944b2")
product2.images.attach(io: file2, filename: "fixation.jpg", content_type: "image/jpg")

puts "Seed done."
