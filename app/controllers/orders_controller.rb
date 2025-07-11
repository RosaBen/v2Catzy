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

        # Créer les order_items avec vérification ET gestion des colonnes manquantes
        cart.items.each do |item|
          # Vérifier que l'item existe encore
          if item && item.persisted?
            begin
              # Essayer avec les nouveaux champs price/quantity
              order_item_attrs = {
                order: @order, 
                item: item
              }
              
              # Ajouter price et quantity seulement si les colonnes existent
              if OrderItem.column_names.include?('price')
                order_item_attrs[:price] = item.price
              end
              
              if OrderItem.column_names.include?('quantity')
                order_item_attrs[:quantity] = 1
              end
              
              OrderItem.create!(order_item_attrs)
              
            rescue ActiveRecord::UnknownAttributeError => e
              # Fallback pour les anciennes structures de DB
              Rails.logger.warn "⚠️ Utilisation de la structure DB ancienne: #{e.message}"
              OrderItem.create!(order: @order, item: item)
            end
          else
            Rails.logger.warn "⚠️ Item #{item&.id} non trouvé lors de la création de commande"
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
          # Ne pas faire échouer la commande si l'email échoue
        end
        
        Rails.logger.info "✅ Commande #{@order.id} créée avec succès pour l'utilisateur #{current_user.id}"
        
      rescue ActiveRecord::InvalidForeignKey => e
        Rails.logger.error "❌ Erreur contrainte FK: #{e.message}"
        
        # Nettoyer le panier qui pourrait contenir des items supprimés
        if cart
          begin
            # Supprimer les items qui n'existent plus
            cart.items.each do |item|
              unless Item.exists?(item.id)
                cart.cart_items.where(item_id: item.id).destroy_all
              end
            end
            cart.reload
          rescue => cleanup_error
            Rails.logger.error "Erreur nettoyage panier: #{cleanup_error.message}"
          end
        end
        
        redirect_to root_path, alert: "Erreur: certains articles ne sont plus disponibles. Votre panier a été mis à jour."
        return
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