class CompleteOrderItemsRestructure < ActiveRecord::Migration[8.0]
  def up
    puts "🔄 Restructuration complète de la table order_items..."
    
    # 1. Sauvegarder les données existantes
    existing_order_items = []
    if table_exists?(:order_items)
      execute(<<-SQL)
        SELECT oi.order_id, oi.item_id, i.price, oi.created_at, oi.updated_at
        FROM order_items oi
        LEFT JOIN items i ON oi.item_id = i.id
        WHERE i.id IS NOT NULL
      SQL
      .each do |row|
        existing_order_items << {
          order_id: row['order_id'],
          item_id: row['item_id'], 
          price: row['price'],
          quantity: 1,
          created_at: row['created_at'],
          updated_at: row['updated_at']
        }
      end
    end
    
    puts "📦 #{existing_order_items.length} order_items à conserver"
    
    # 2. Supprimer complètement la table order_items
    drop_table :order_items if table_exists?(:order_items)
    
    # 3. Recréer la table order_items avec la bonne structure
    create_table :order_items do |t|
      t.references :order, null: false
      t.references :item, null: false  
      t.decimal :price, precision: 8, scale: 2, null: false
      t.integer :quantity, default: 1, null: false
      t.timestamps
    end
    
    # 4. Ajouter les index s'ils n'existent pas
    add_index :order_items, :order_id unless index_exists?(:order_items, :order_id)
    add_index :order_items, :item_id unless index_exists?(:order_items, :item_id)
    
    # 5. Ajouter les contraintes FK avec les bonnes options
    add_foreign_key :order_items, :orders, on_delete: :cascade
    add_foreign_key :order_items, :items, on_delete: :restrict
    
    # 6. Restaurer les données
    existing_order_items.each do |data|
      # Vérifier que l'order et l'item existent encore
      if ActiveRecord::Base.connection.exec_query("SELECT 1 FROM orders WHERE id = #{data[:order_id]}").any? &&
         ActiveRecord::Base.connection.exec_query("SELECT 1 FROM items WHERE id = #{data[:item_id]}").any?
        
        execute <<-SQL
          INSERT INTO order_items (order_id, item_id, price, quantity, created_at, updated_at)
          VALUES (#{data[:order_id]}, #{data[:item_id]}, #{data[:price]}, #{data[:quantity]}, '#{data[:created_at]}', '#{data[:updated_at]}')
        SQL
      end
    end
    
    puts "✅ Table order_items restructurée avec succès"
  end

  def down
    # Fallback simple
    drop_table :order_items if table_exists?(:order_items)
    
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.timestamps
    end
  end
end
