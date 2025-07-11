class OrdersController < ApplicationController  
  def success
    # Vérifier si l'utilisateur est connecté
    unless user_signed_in?
      redirect_to root_path, alert: "Vous devez être connecté pour voir cette page."
      return
    end
    
    # Vérifier qu'on a les informations de checkout en session
    unless session[:checkout_cart_id] && session[:checkout_total_amount] && session[:checkout_items]
      Rails.logger.error "❌ Informations de checkout manquantes en session pour utilisateur #{current_user.id}"
      redirect_to root_path, alert: "Erreur lors de la validation de votre commande."
      return
    end

    begin
      # Créer la commande en base de données
      order = current_user.orders.build(
        amount: session[:checkout_total_amount] # Montant en centimes
      )

      if order.save
        Rails.logger.info "✅ Commande #{order.id} créée pour utilisateur #{current_user.id}"

        # Créer les order_items à partir des informations stockées en session
        session[:checkout_items].each do |item_data|
          item = Item.find_by(id: item_data['id'])
          if item
            order_item = order.order_items.build(
              item: item,
              price: (item_data['price'].to_f * 100).round, # Prix en centimes
              quantity: 1
            )
            
            unless order_item.save
              Rails.logger.error "❌ Erreur création order_item: #{order_item.errors.full_messages}"
            end
          else
            Rails.logger.warn "⚠️ Item #{item_data['id']} introuvable lors de la création de l'order_item"
          end
        end

        # Vider le panier après création réussie de la commande
        cart = current_user.cart
        if cart && cart.items.any?
          cart.items.clear
          Rails.logger.info "✅ Panier vidé après création de la commande #{order.id}"
        end

        # Nettoyer les informations de session
        session.delete(:checkout_cart_id)
        session.delete(:checkout_total_amount)
        session.delete(:checkout_items)

        @order = order
        @success_message = "Votre commande ##{order.id} a été créée avec succès ! Merci pour votre achat."
        Rails.logger.info "✅ Commande #{order.id} finalisée avec succès pour utilisateur #{current_user.id}"

      else
        Rails.logger.error "❌ Erreur création commande: #{order.errors.full_messages}"
        redirect_to root_path, alert: "Erreur lors de la création de votre commande."
      end

    rescue => e
      Rails.logger.error "❌ Erreur lors de la création de la commande: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_to root_path, alert: "Une erreur est survenue lors de la finalisation de votre commande."
    end
  end
end