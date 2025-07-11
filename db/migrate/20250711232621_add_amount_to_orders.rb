class AddAmountToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :amount, :decimal, precision: 8, scale: 2, null: false, default: 0
  end
end
