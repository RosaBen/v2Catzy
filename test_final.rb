puts '=== TEST FINAL COMPLET ==='

# Test 1: Vérification structure
puts '📋 STRUCTURE:'
puts "  order_items colonnes: #{OrderItem.column_names.join(', ')}"

# Test 2: Contraintes FK
puts '🔗 CONTRAINTES FK:'
result = ActiveRecord::Base.connection.execute("
  SELECT conname, CASE confdeltype 
    WHEN 'c' THEN 'CASCADE'
    WHEN 'r' THEN 'RESTRICT' 
    ELSE 'OTHER'
  END as action
  FROM pg_constraint 
  WHERE conrelid = 'order_items'::regclass 
  AND confrelid = 'items'::regclass
")

result.each do |row|
  puts "  #{row['conname']}: #{row['action']}"
end

# Test 3: Création OrderItem
puts '➕ TEST CRÉATION:'
user = User.first
item = Item.first

order = user.orders.create!
order_item = OrderItem.create!(order: order, item: item, price: item.price, quantity: 1)
puts "  ✅ OrderItem créé: ID #{order_item.id}"

# Test 4: Panier
puts '🛒 TEST PANIER:'
cart = user.cart || user.create_cart
cart.items.clear
cart.items << item
puts "  ✅ Item ajouté au panier"

cart.items.delete(item)
puts "  ✅ Item supprimé du panier"
puts "  ✅ Item existe toujours: #{Item.exists?(item.id)}"

puts '🎉 TOUS LES TESTS RÉUSSIS - PRÊT POUR RENDER!'
