class UpdateCartItemsForeignKeyConstraint < ActiveRecord::Migration[8.0]
  def up
    # Supprimer l'ancienne contrainte de clé étrangère
    remove_foreign_key :cart_items, :items if foreign_key_exists?(:cart_items, :items)
    
    # Ajouter la nouvelle contrainte avec ON DELETE CASCADE
    add_foreign_key :cart_items, :items, on_delete: :cascade
    
    puts "✅ Contrainte de clé étrangère mise à jour avec CASCADE"
  end

  def down
    # Restaurer l'ancienne contrainte
    remove_foreign_key :cart_items, :items if foreign_key_exists?(:cart_items, :items)
    add_foreign_key :cart_items, :items
    
    puts "⚠️  Contrainte de clé étrangère restaurée sans CASCADE"
  end
end
