class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :item
  
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
end
