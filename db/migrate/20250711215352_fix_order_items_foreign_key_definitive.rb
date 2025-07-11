class FixOrderItemsForeignKeyDefinitive < ActiveRecord::Migration[8.0]
  def up
    # Supprimer la contrainte FK problématique order_items -> items
    if foreign_key_exists?(:order_items, :items)
      remove_foreign_key :order_items, :items
    end
    
    # Ajouter les colonnes price et quantity si elles n'existent pas
    unless column_exists?(:order_items, :price)
      add_column :order_items, :price, :decimal, precision: 8, scale: 2
    end
    
    unless column_exists?(:order_items, :quantity)
      add_column :order_items, :quantity, :integer, default: 1
    end
    
    # Remettre la FK avec CASCADE (si item supprimé, order_item supprimé aussi)
    add_foreign_key :order_items, :items, on_delete: :cascade
  end

  def down
    remove_foreign_key :order_items, :items if foreign_key_exists?(:order_items, :items)
    add_foreign_key :order_items, :items # Contrainte par défaut (RESTRICT)
    
    remove_column :order_items, :price if column_exists?(:order_items, :price)
    remove_column :order_items, :quantity if column_exists?(:order_items, :quantity)
  end
end
