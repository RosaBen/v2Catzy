namespace :production do
  desc "Force la correction des contraintes FK en production"
  task fix_constraints: :environment do
    puts "🔧 Correction forcée des contraintes FK en production..."
    
    begin
      # Vérifier l'état actuel
      puts "📊 État actuel des contraintes:"
      result = ActiveRecord::Base.connection.execute(<<-SQL)
        SELECT 
          conname as constraint_name,
          CASE confdeltype 
            WHEN 'a' THEN 'NO ACTION'
            WHEN 'r' THEN 'RESTRICT' 
            WHEN 'c' THEN 'CASCADE'
            WHEN 'n' THEN 'SET NULL'
            WHEN 'd' THEN 'SET DEFAULT'
          END as delete_action
        FROM pg_constraint 
        WHERE conrelid = 'order_items'::regclass 
        AND confrelid = 'items'::regclass
        AND contype = 'f'
      SQL
      
      result.each do |row|
        puts "  #{row['constraint_name']}: #{row['delete_action']}"
      end
      
      # Compter les order_items existants
      order_items_count = OrderItem.count
      puts "📈 #{order_items_count} order_items existants"
      
      if order_items_count > 0
        puts "⚠️  Il y a des order_items existants, la contrainte RESTRICT est appropriée"
      else
        puts "✅ Aucun order_item existant, contrainte FK sûre à modifier"
      end
      
      # Vérifier les colonnes
      order_items_columns = ActiveRecord::Base.connection.columns(:order_items).map(&:name)
      puts "📋 Colonnes order_items: #{order_items_columns.join(', ')}"
      
      has_price = order_items_columns.include?('price')
      has_quantity = order_items_columns.include?('quantity')
      
      puts "💰 Colonne price: #{has_price ? '✅' : '❌'}"
      puts "🔢 Colonne quantity: #{has_quantity ? '✅' : '❌'}"
      
      unless has_price && has_quantity
        puts "❌ Les colonnes price/quantity sont manquantes. Les migrations doivent être appliquées!"
        exit 1
      end
      
      puts "✅ Diagnostic terminé. Les contraintes sont prêtes."
      
    rescue => e
      puts "❌ Erreur lors du diagnostic: #{e.message}"
      puts e.backtrace.first(5).join("\n")
    end
  end
  
  desc "Nettoie en urgence les données en production"
  task emergency_cleanup: :environment do
    puts "🚨 NETTOYAGE D'URGENCE EN PRODUCTION"
    puts "⚠️  Cette tâche va supprimer les données incohérentes"
    
    begin
      # Compter les order_items orphelins
      orphaned_count = OrderItem.joins("LEFT JOIN items ON order_items.item_id = items.id")
                               .where("items.id IS NULL").count
      
      if orphaned_count > 0
        puts "🧹 Suppression de #{orphaned_count} order_items orphelins..."
        OrderItem.joins("LEFT JOIN items ON order_items.item_id = items.id")
                 .where("items.id IS NULL").delete_all
        puts "✅ Order_items orphelins supprimés"
      else
        puts "✅ Aucun order_item orphelin trouvé"
      end
      
      # Mettre à jour les price/quantity manquants
      missing_price = OrderItem.where(price: nil).count
      missing_quantity = OrderItem.where(quantity: nil).count
      
      if missing_price > 0 || missing_quantity > 0
        puts "🔄 Mise à jour de #{missing_price} prix et #{missing_quantity} quantités manquants..."
        
        OrderItem.includes(:item).where("price IS NULL OR quantity IS NULL").each do |order_item|
          if order_item.item
            order_item.update!(
              price: order_item.price || order_item.item.price,
              quantity: order_item.quantity || 1
            )
          end
        end
        puts "✅ Prix et quantités mis à jour"
      else
        puts "✅ Tous les order_items ont un prix et une quantité"
      end
      
      puts "✅ Nettoyage d'urgence terminé!"
      
    rescue => e
      puts "❌ Erreur lors du nettoyage: #{e.message}"
      puts e.backtrace.first(5).join("\n")
    end
  end
end
