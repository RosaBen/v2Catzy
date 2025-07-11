namespace :db do
  desc "Nettoie les order_items orphelins et met à jour les prix/quantités"
  task cleanup_order_items: :environment do
    puts "🧹 Nettoyage des order_items..."
    
    # Supprimer les order_items orphelins (items supprimés)
    orphaned_order_items = OrderItem.includes(:item).where(items: { id: nil })
    orphaned_count = orphaned_order_items.count
    
    if orphaned_count > 0
      puts "❌ Suppression de #{orphaned_count} order_items orphelins..."
      orphaned_order_items.delete_all
    else
      puts "✅ Aucun order_item orphelin trouvé"
    end
    
    # Mettre à jour les order_items sans prix ni quantité
    order_items_without_price = OrderItem.where(price: nil).or(OrderItem.where(quantity: nil))
    update_count = order_items_without_price.count
    
    if update_count > 0
      puts "🔄 Mise à jour de #{update_count} order_items sans prix/quantité..."
      order_items_without_price.includes(:item).each do |order_item|
        if order_item.item
          order_item.update!(
            price: order_item.item.price,
            quantity: 1
          )
        end
      end
    else
      puts "✅ Tous les order_items ont déjà un prix et une quantité"
    end
    
    puts "✅ Nettoyage terminé !"
  end
end
