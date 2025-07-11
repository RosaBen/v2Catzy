class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :items, through: :order_items
  
  # Calculer le total de la commande
  def total_price
    order_items.sum { |order_item| order_item.price * order_item.quantity }
  end
end