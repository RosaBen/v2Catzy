class OrdersController < ApplicationController  
  def success
    # Vérifier si l'utilisateur est connecté
    unless user_signed_in?
      redirect_to root_path, alert: "Vous devez être connecté pour voir cette page."
      return
    end
    
    # Vérifier qu'on a les informations de checkout en session
    unless session[:checkout_cart_id] || session[:checkout_total_amount] || session[:checkout_items]
      Rails.logger.error "❌ Informations de checkout manquantes en session pour utilisateur #{current_user.id}"
      
      # Fallback : juste vider le panier et afficher un message générique
      cart = current_user.cart
      if cart && cart.items.any?
        cart.items.clear
        Rails.logger.info "✅ Panier vidé après paiement Stripe pour utilisateur #{current_user.id}"
      end
      
      @success_message = "Votre paiement a été traité avec succès ! Merci pour votre commande."
      return
    end

    begin
      # Vérifier si la colonne amount existe (migration appliquée)
      amount_column_exists = Order.column_names.include?('amount')
      
      # Créer la commande en base de données
      if amount_column_exists
        order = current_user.orders.build(
          amount: session[:checkout_total_amount] # Montant en centimes
        )
      else
        # Fallback si la migration n'est pas encore appliquée
        Rails.logger.warn "⚠️ Colonne 'amount' manquante dans orders, création sans montant"
        order = current_user.orders.build
      end

      if order.save
        Rails.logger.info "✅ Commande #{order.id} créée pour utilisateur #{current_user.id}"

        # Créer les order_items à partir des informations stockées en session
        if session[:checkout_items]
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
        
        # Fallback : vider le panier quand même
        cart = current_user.cart
        if cart && cart.items.any?
          cart.items.clear
        end
        
        @success_message = "Votre paiement a été traité avec succès ! Merci pour votre commande."
      end

    rescue => e
      Rails.logger.error "❌ Erreur lors de la création de la commande: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      # Fallback : vider le panier quand même et afficher un message générique
      begin
        cart = current_user.cart
        if cart && cart.items.any?
          cart.items.clear
          Rails.logger.info "✅ Panier vidé en mode fallback après erreur"
        end
      rescue => cart_error
        Rails.logger.error "❌ Erreur même pour vider le panier: #{cart_error.message}"
      end
      
      @success_message = "Votre paiement a été traité avec succès ! Merci pour votre commande."
    end
  end
end