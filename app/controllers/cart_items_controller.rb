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
    cart = current_cart
    item = Item.find(params[:item_id])

    if cart && item
      # CORRECTION: supprimer l'item DU PANIER, pas l'item lui-même
      cart.items.delete(item)  # delete au lieu de destroy
      
      # Si l'utilisateur n'est pas authentifié, le rediriger vers la liste des items
      if user_signed_in?
        redirect_to cart_path, notice: "Article supprimé du panier."
      else
        redirect_to items_path, notice: "Article supprimé du panier. Connectez-vous pour sauvegarder votre panier."
      end
    else
      # En cas d'erreur, rediriger selon le statut d'authentification
      if user_signed_in?
        redirect_to cart_path, alert: "Impossible de supprimer l'article."
      else
        redirect_to items_path, alert: "Impossible de supprimer l'article."
      end
    end
  end

end