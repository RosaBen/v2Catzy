class CartItemsController < ApplicationController
  # before_action :authenticate_user!

  def create
    item = Item.find(params[:item_id])
    cart = current_cart

    if cart.items.include?(item)
      redirect_to item_path(item), notice: "Cet article est déjà dans votre panier."
    else
      cart.items << item
      redirect_to item_path(item), notice: "Article ajouté au panier."
    end
  end

  def destroy
  cart = current_user.cart
  item = Item.find(params[:item_id])

  if cart && item
    cart.items.destroy(item)
    redirect_to cart_path, notice: "Article supprimé du panier."
  else
    redirect_to cart_path, alert: "Impossible de supprimer l'article."
  end
end

end