# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Ops3dSetting.find_or_create_by!(id: 1) do |settings|
  settings.shipping_mode = "flat_rate"
  settings.shipping_price_cents = 490
end

admin = User.find_or_create_by!(email: "admin@ops3d.local") do |user|
  user.first_name = "Admin"
  user.last_name = "Ops3d"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.admin = true
end

cat1 = Category.find_or_create_by!(name: "Fixations")
cat2 = Category.find_or_create_by!(name: "Supports")

Product.find_or_create_by!(name: "Support caméra") do |product|
  product.description = "Support imprimé 3D robuste"
  product.price_cents = 2490
  product.category = cat2
  product.published = true
  product.available = true
end
