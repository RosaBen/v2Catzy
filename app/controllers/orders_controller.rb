class OrdersController < ApplicationController
  before_action :authenticate_user!
  
  def success
    cart = current_user.cart

    if cart && cart.items.any?
      # Créer la commande
      @order = current_user.orders.create

      cart.items.each do |item|
        OrderItem.create(order: @order, item: item)
      end

      # Vider le panier
      cart.items.clear

      if @order.persisted?
        # Envoi des emails
        OrderMailer.order_confirmation(@order).deliver_now
        OrderMailer.order_notification_admin(@order).deliver_now
      else
        Rails.logger.error "Commande non persistée !"
      end
    else
      redirect_to root_path, alert: "Aucun article dans le panier."
    end
  end

  

end