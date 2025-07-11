class ForceFixOrderItemsConstraint < ActiveRecord::Migration[8.0]
  def up
    # Supprimer toutes les contraintes FK existantes sur order_items -> items
    execute <<-SQL
      DO $$
      DECLARE
          constraint_name TEXT;
      BEGIN
          -- Trouver et supprimer toutes les contraintes FK de order_items vers items
          FOR constraint_name IN 
              SELECT conname 
              FROM pg_constraint 
              WHERE conrelid = 'order_items'::regclass 
              AND confrelid = 'items'::regclass 
              AND contype = 'f'
          LOOP
              EXECUTE 'ALTER TABLE order_items DROP CONSTRAINT ' || constraint_name;
              RAISE NOTICE 'Dropped constraint: %', constraint_name;
          END LOOP;
      END $$;
    SQL
    
    # Ajouter la nouvelle contrainte avec RESTRICT
    add_foreign_key :order_items, :items, on_delete: :restrict
    
    puts "✅ Contrainte FK order_items -> items mise à jour avec RESTRICT"
  end

  def down
    remove_foreign_key :order_items, :items
    add_foreign_key :order_items, :items  # Sans restriction (par défaut)
  end
end
