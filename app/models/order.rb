class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :items, through: :order_items
  
  # Calculer le total de la commande (compatible anciennes et nouvelles structures)
  def total_price
    if OrderItem.column_names.include?('price') && OrderItem.column_names.include?('quantity')
      # Nouvelle structure avec price et quantity dans order_items
      order_items.sum { |order_item| (order_item.price || 0) * (order_item.quantity || 1) }
    else
      # Ancienne structure, utiliser le prix de l'item
      order_items.includes(:item).sum { |order_item| order_item.item&.price || 0 }
    end
  end
end