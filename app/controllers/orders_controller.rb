class OrdersController < ApplicationController  
  def success
    # Vérifier si l'utilisateur est connecté
    unless user_signed_in?
      redirect_to root_path, alert: "Vous devez être connecté pour voir cette page."
      return
    end
    
    Rails.logger.info "✅ Utilisateur #{current_user.id} arrivé sur page de succès"

    begin
      # Étape 1: Essayer de traiter les commandes en attente depuis le stockage
      created_orders = PendingOrderService.process_pending_orders_for_user(current_user)
      
      # Étape 2: Si pas de commandes créées, essayer avec les données de session
      if created_orders.empty? && (session[:checkout_items] || session[:checkout_total_amount])
        Rails.logger.info "✅ Tentative de création depuis session pour utilisateur #{current_user.id}"
        created_order = create_order_from_session
        created_orders << created_order if created_order
      end
      
      # Étape 3: Nettoyer la session et le panier
      cleanup_after_purchase
      
      # Étape 4: Préparer l'affichage
      if created_orders.any?
        @order = created_orders.last # Prendre la dernière commande créée
        @success_message = "Votre commande ##{@order.id} a été créée avec succès ! Merci pour votre achat."
        Rails.logger.info "✅ Commande #{@order.id} finalisée avec succès pour utilisateur #{current_user.id}"
      else
        Rails.logger.warn "⚠️ Aucune commande créée mais paiement réussi pour utilisateur #{current_user.id}"
        @success_message = "Votre paiement a été traité avec succès ! Merci pour votre commande."
      end

    rescue => e
      Rails.logger.error "❌ Erreur critique page success: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      # Fallback ultime: au moins vider le panier
      cleanup_after_purchase
      @success_message = "Votre paiement a été traité avec succès ! Merci pour votre commande."
    end
  end

  private

  def create_order_from_session
    return nil unless session[:checkout_items]

    begin
      # Vérifier si on peut utiliser la colonne amount
      can_use_amount = Order.column_names.include?('amount')
      
      order_attributes = {}
      order_attributes[:amount] = session[:checkout_total_amount] if can_use_amount && session[:checkout_total_amount]
      
      order = current_user.orders.build(order_attributes)
      
      if order.save
        Rails.logger.info "✅ Order #{order.id} créé depuis session"
        
        # Créer les order_items
        session[:checkout_items].each do |item_data|
          item = Item.find_by(id: item_data['id'])
          if item
            order_item = order.order_items.build(
              item: item,
              price: (item_data['price'].to_f * 100).round,
              quantity: item_data['quantity'] || 1
            )
            
            unless order_item.save
              Rails.logger.error "❌ Erreur création order_item: #{order_item.errors.full_messages}"
            end
          end
        end
        
        order
      else
        Rails.logger.error "❌ Erreur création order depuis session: #{order.errors.full_messages}"
        nil
      end
    rescue => e
      Rails.logger.error "❌ Exception création order depuis session: #{e.message}"
      nil
    end
  end

  def cleanup_after_purchase
    begin
      # Vider le panier
      cart = current_user.cart
      if cart && cart.items.any?
        cart.items.clear
        Rails.logger.info "✅ Panier vidé pour utilisateur #{current_user.id}"
      end
      
      # Nettoyer la session
      session.delete(:checkout_cart_id)
      session.delete(:checkout_total_amount)
      session.delete(:checkout_items)
      
    rescue => e
      Rails.logger.error "❌ Erreur nettoyage après achat: #{e.message}"
    end
  end
end