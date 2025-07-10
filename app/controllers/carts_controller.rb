class CartsController < ApplicationController
  before_action :authenticate_user!

  def show
    @cart = current_user.cart
    @total_price = @cart.items.sum(&:price)
  end
end