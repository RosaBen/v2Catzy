namespace :db do
  desc "Clean up orphaned cart_items"
  task cleanup_cart_items: :environment do
    puts "🧹 Nettoyage des cart_items orphelins..."
    
    # Supprimer les cart_items qui référencent des items qui n'existent plus
    orphaned_count = CartItem.joins("LEFT JOIN items ON cart_items.item_id = items.id")
                             .where("items.id IS NULL")
                             .count
    
    if orphaned_count > 0
      puts "🗑️  Suppression de #{orphaned_count} cart_items orphelins..."
      CartItem.joins("LEFT JOIN items ON cart_items.item_id = items.id")
              .where("items.id IS NULL")
              .delete_all
      puts "✅ Cart_items orphelins supprimés!"
    else
      puts "✅ Aucun cart_item orphelin trouvé"
    end
    
    # Supprimer les paniers vides et anciens (plus de 30 jours)
    old_empty_carts = Cart.left_joins(:cart_items)
                         .where(cart_items: { id: nil })
                         .where("carts.created_at < ?", 30.days.ago)
    
    old_count = old_empty_carts.count
    if old_count > 0
      puts "🗑️  Suppression de #{old_count} paniers vides de plus de 30 jours..."
      old_empty_carts.destroy_all
      puts "✅ Paniers vides supprimés!"
    else
      puts "✅ Aucun panier vide ancien trouvé"
    end
    
    puts "🎉 Nettoyage terminé!"
  end
end
