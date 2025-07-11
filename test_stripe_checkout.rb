#!/usr/bin/env ruby

# Test du checkout Stripe en conditions réelles
puts "🧪 Test du checkout Stripe..."

# Charger l'environnement Rails
require_relative 'config/environment'

# Créer un utilisateur de test
user = User.create!(
  email: 'test@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Test',
  last_name: 'User'
)

# Créer un item de test
item = Item.create!(
  title: 'Test Stripe Product',
  description: 'Produit de test pour Stripe',
  price: 19.99,
  image_url: 'http://example.com/test.jpg'
)

# Créer un panier et ajouter l'item
cart = user.create_cart
cart.items << item

puts "✅ Setup terminé:"
puts "  - Utilisateur: #{user.email}"
puts "  - Item: #{item.title} (#{item.price}€)"
puts "  - Panier: #{cart.items.count} item(s)"

# Simuler la création de session Stripe comme dans le contrôleur
begin
  base_url = "http://localhost:3000"
  
  session = Stripe::Checkout::Session.create(
    payment_method_types: ['card'],
    line_items: cart.items.map do |item|
      {
        price_data: {
          currency: 'eur',
          product_data: {
            name: item.title,
            description: item.description
          },
          unit_amount: (item.price.to_f * 100).round
        },
        quantity: 1
      }
    end,
    mode: 'payment',
    success_url: base_url + "/order/success",
    cancel_url: base_url + "/cart"
  )
  
  puts "✅ Session Stripe créée avec succès!"
  puts "  - Session ID: #{session.id}"
  puts "  - URL: #{session.url}"
  puts "  - Montant: #{(item.price.to_f * 100).round} centimes"
  
rescue => e
  puts "❌ Erreur: #{e.message}"
  puts "  - Type: #{e.class}"
  puts "  - Backtrace:"
  e.backtrace.first(5).each { |line| puts "    #{line}" }
end

# Nettoyer
cart.destroy
item.destroy
user.destroy

puts "🧹 Nettoyage terminé"
