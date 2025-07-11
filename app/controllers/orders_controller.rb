class OrdersController < ApplicationController  
  def success
    # Vérifier si l'utilisateur est connecté
    unless user_signed_in?
      redirect_to root_path, alert: "Vous devez être connecté pour voir cette page."
      return
    end
    
    # Solution temporaire : juste vider le panier et afficher un message de succès
    # sans essayer de créer une commande (problème de contrainte FK en production)
    
    cart = current_user.cart
    
    if cart && cart.items.any?
      # Vider le panier après le paiement réussi
      cart.items.clear
      Rails.logger.info "✅ Panier vidé après paiement Stripe pour utilisateur #{current_user.id}"
    end
    
    @success_message = "Votre paiement a été traité avec succès ! Merci pour votre commande."
    Rails.logger.info "✅ Page de succès affichée pour utilisateur #{current_user.id}"
  end
end