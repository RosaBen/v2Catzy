class OrdersController < ApplicationController
  # Retirer l'authentification obligatoire pour la page de succès
  # before_action :authenticate_user!
  
  def success
    # Vérifier si l'utilisateur est connecté
    unless user_signed_in?
      redirect_to root_path, alert: "Vous devez être connecté pour voir cette page."
      return
    end
    
    cart = current_user.cart

    if cart && cart.items.any?
      begin
        # Créer la commande
        @order = current_user.orders.create!

        cart.items.each do |item|
          OrderItem.create!(order: @order, item: item, price: item.price, quantity: 1)
        end

        # Vider le panier
        cart.items.clear

        # Envoi des emails
        begin
          OrderMailer.order_confirmation(@order).deliver_now
          OrderMailer.order_notification_admin(@order).deliver_now
        rescue => e
          Rails.logger.error "Erreur envoi email: #{e.message}"
          # Ne pas faire échouer la commande si l'email échoue
        end
        
        Rails.logger.info "✅ Commande #{@order.id} créée avec succès pour l'utilisateur #{current_user.id}"
        
      rescue => e
        Rails.logger.error "❌ Erreur création commande: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        redirect_to root_path, alert: "Erreur lors de la création de votre commande. Contactez le support."
        return
      end
    else
      redirect_to root_path, notice: "Votre commande a été traitée avec succès !"
    end
  end

  

end