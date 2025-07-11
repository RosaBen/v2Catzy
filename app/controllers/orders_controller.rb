class OrdersController < ApplicationController  
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

        # Créer les order_items
        cart.items.each do |item|
          if item && item.persisted?
            OrderItem.create!(
              order: @order, 
              item: item, 
              price: item.price, 
              quantity: 1
            )
          end
        end

        # Vérifier que la commande a au moins un item
        if @order.order_items.empty?
          @order.destroy
          redirect_to root_path, alert: "Erreur: aucun article valide dans le panier."
          return
        end

        # Vider le panier
        cart.items.clear

        # Envoi des emails
        begin
          OrderMailer.order_confirmation(@order).deliver_now
          OrderMailer.order_notification_admin(@order).deliver_now
        rescue => e
          Rails.logger.error "Erreur envoi email: #{e.message}"
        end
        
        Rails.logger.info "✅ Commande #{@order.id} créée avec succès"
        
      rescue ActiveRecord::InvalidForeignKey => e
        Rails.logger.error "❌ Erreur contrainte FK: #{e.message}"
        redirect_to root_path, alert: "Erreur: certains articles ne sont plus disponibles."
        return
      rescue => e
        Rails.logger.error "❌ Erreur création commande: #{e.message}"
        redirect_to root_path, alert: "Erreur lors de la création de votre commande."
        return
      end
    else
      redirect_to root_path, notice: "Votre commande a été traitée avec succès !"
    end
  end
end