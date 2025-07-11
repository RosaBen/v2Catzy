class CreateCarts < ActiveRecord::Migration[8.0]
  def change
    create_table :carts do |t|
      t.references :user, null: false

      t.timestamps
    end
    add_foreign_key :carts, :users, on_delete: :cascade
  end
end
