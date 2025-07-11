class CleanupOrphanedCartItems < ActiveRecord::Migration[8.0]
  def up
    # Supprimer les cart_items qui référencent des items qui n'existent plus
    execute <<-SQL
      DELETE FROM cart_items 
      WHERE item_id NOT IN (SELECT id FROM items);
    SQL
    
    # Supprimer les paniers vides anciens (plus de 7 jours)
    execute <<-SQL
      DELETE FROM carts 
      WHERE id NOT IN (SELECT DISTINCT cart_id FROM cart_items WHERE cart_id IS NOT NULL)
      AND created_at < NOW() - INTERVAL '7 days';
    SQL
    
    puts "✅ Nettoyage des cart_items orphelins terminé"
  end

  def down
    # Pas de rollback pour cette migration de nettoyage
    puts "⚠️  Cette migration de nettoyage ne peut pas être annulée"
  end
end
