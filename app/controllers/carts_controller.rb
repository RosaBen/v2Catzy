class CartsController < ApplicationController
  # before_action :authenticate_user!

  def show
    # Si l'utilisateur n'est pas connecté et n'a pas de panier, rediriger vers les items
    if !user_signed_in? && (current_cart.nil? || current_cart.items.empty?)
      redirect_to items_path, notice: "Votre panier est vide. Connectez-vous pour sauvegarder vos articles."
      return
    end
    
    @cart = current_cart
    @total_price = @cart.items.sum(&:price) if @cart
  end
end