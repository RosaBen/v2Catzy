class FixOrderItemsForeignKeyConstraint < ActiveRecord::Migration[8.0]
  def change
    # Supprimer l'ancienne contrainte
    remove_foreign_key :order_items, :items if foreign_key_exists?(:order_items, :items)
    
    # Ajouter la nouvelle contrainte avec RESTRICT (empêche la suppression d'un item s'il a des commandes)
    add_foreign_key :order_items, :items, on_delete: :restrict
  end
end
