class Item < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items
  has_many :cart_items
  has_many :carts, through: :cart_items

  validates :description, length: { maximum: 500 }
  validates :title, length: { maximum: 30 }
  validates :price, :image_url, :title, presence: true
  validates :price, numericality: { greater_than: 0 }
end
