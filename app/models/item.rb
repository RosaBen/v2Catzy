class Item < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items
  has_many :cart_items, dependent: :destroy
  has_many :carts, through: :cart_items

  validates :description, length: { maximum: 500 }
  validates :title, length: { maximum: 30 }
  validates :price, :image_url, :title, presence: true
  validates :price, numericality: { greater_than: 0 }

  # Méthode pour vérifier si l'item peut être supprimé en toute sécurité
  def can_be_deleted?
    order_items.empty?
  end

  # Méthode de suppression sécurisée
  def safe_destroy
    if can_be_deleted?
      # Supprimer d'abord les cart_items (paniers non finalisés)
      cart_items.destroy_all
      # Puis supprimer l'item
      destroy
    else
      errors.add(:base, "Cet article ne peut pas être supprimé car il fait partie de commandes existantes")
      false
    end
  end
end
