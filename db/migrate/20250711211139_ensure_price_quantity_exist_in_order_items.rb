class EnsurePriceQuantityExistInOrderItems < ActiveRecord::Migration[8.0]
  def up
    # Ajouter price seulement si elle n'existe pas
    unless column_exists?(:order_items, :price)
      add_column :order_items, :price, :decimal
      puts "✅ Colonne price ajoutée à order_items"
    else
      puts "✅ Colonne price existe déjà dans order_items"
    end
    
    # Ajouter quantity seulement si elle n'existe pas
    unless column_exists?(:order_items, :quantity)
      add_column :order_items, :quantity, :integer
      puts "✅ Colonne quantity ajoutée à order_items"
    else
      puts "✅ Colonne quantity existe déjà dans order_items"
    end
  end

  def down
    remove_column :order_items, :price if column_exists?(:order_items, :price)
    remove_column :order_items, :quantity if column_exists?(:order_items, :quantity)
  end
end
