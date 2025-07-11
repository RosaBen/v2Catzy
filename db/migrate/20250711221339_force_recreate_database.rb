class ForceRecreateDatabase < ActiveRecord::Migration[8.0]
  def up
    # Cette migration force la reconstruction complète en cas de problèmes de cohérence
    puts "🔄 Reconstruction forcée de la structure DB pour Render..."
    
    # 1. Supprimer toutes les contraintes FK existantes qui posent problème
    execute <<-SQL
      DO $$
      DECLARE
          constraint_record RECORD;
      BEGIN
          -- Supprimer toutes les FK constraints sur order_items et cart_items
          FOR constraint_record IN 
              SELECT conname, conrelid::regclass as table_name
              FROM pg_constraint 
              WHERE contype = 'f' 
              AND (conrelid = 'order_items'::regclass OR conrelid = 'cart_items'::regclass)
          LOOP
              BEGIN
                  EXECUTE 'ALTER TABLE ' || constraint_record.table_name || ' DROP CONSTRAINT IF EXISTS ' || constraint_record.conname;
                  RAISE NOTICE 'Dropped constraint: % from %', constraint_record.conname, constraint_record.table_name;
              EXCEPTION WHEN OTHERS THEN
                  RAISE NOTICE 'Could not drop constraint: % from %', constraint_record.conname, constraint_record.table_name;
              END;
          END LOOP;
      END $$;
    SQL
    
    # 2. S'assurer que les colonnes price et quantity existent dans order_items
    unless column_exists?(:order_items, :price)
      add_column :order_items, :price, :decimal, precision: 10, scale: 2
      puts "✅ Colonne price ajoutée à order_items"
    end
    
    unless column_exists?(:order_items, :quantity)
      add_column :order_items, :quantity, :integer, default: 1
      puts "✅ Colonne quantity ajoutée à order_items"
    end
    
    # 3. Recréer les contraintes FK proprement
    # Cart items -> CASCADE (si item supprimé, cart_item supprimé)
    add_foreign_key :cart_items, :carts, on_delete: :cascade unless foreign_key_exists?(:cart_items, :carts)
    add_foreign_key :cart_items, :items, on_delete: :cascade unless foreign_key_exists?(:cart_items, :items)
    
    # Order items -> CASCADE (si item supprimé, order_item supprimé)
    add_foreign_key :order_items, :orders, on_delete: :cascade unless foreign_key_exists?(:order_items, :orders)
    add_foreign_key :order_items, :items, on_delete: :cascade unless foreign_key_exists?(:order_items, :items)
    
    # Orders -> Corriger spécifiquement la contrainte fk_rails_f868b47f6a
    if foreign_key_exists?(:orders, :users)
      remove_foreign_key :orders, :users
      puts "✅ Ancienne contrainte orders->users supprimée"
    end
    add_foreign_key :orders, :users, on_delete: :cascade
    puts "✅ Nouvelle contrainte orders->users en CASCADE"
    
    # Carts -> SET NULL (si user supprimé, cart devient orphelin temporairement)
    add_foreign_key :carts, :users, on_delete: :nullify unless foreign_key_exists?(:carts, :users)
    
    puts "✅ Structure DB complètement reconstruite avec contraintes CASCADE"
  end

  def down
    # Ne rien faire au rollback pour éviter de casser encore
    puts "⚠️  Rollback non implémenté volontairement (structure en place)"
  end
end
