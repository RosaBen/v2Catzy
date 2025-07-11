class CheckoutController < ApplicationController
  before_action :authenticate_user!

 def create
   item = Item.find(params[:item_id])

   begin
     session = Stripe::Checkout::Session.create(
       payment_method_types: [ "card" ],
       line_items: [ {
         price_data: {
           currency: "eur",
           product_data: {
             name: item.title,
             description: item.description
           },
           unit_amount: (item.price * 100).to_i
         },
         quantity: 1
       } ],
       mode: "payment",
       success_url: request.base_url + "/?success=true",
       cancel_url: request.base_url + "/?canceled=true",
     )

     redirect_to session.url, allow_other_host: true
   rescue Stripe::StripeError => e
     redirect_to item_path(item), alert: "Erreur lors de la création du paiement: #{e.message}"
   rescue => e
     Rails.logger.error "Erreur checkout: #{e.message}"
     Rails.logger.error e.backtrace.join("\n")
     redirect_to item_path(item), alert: "Une erreur inattendue s'est produite. Veuillez réessayer."
   end
 end

 def create_cart_checkout
   cart = current_cart

   if cart.blank? || cart.items.empty?
     redirect_to cart_path, alert: "Votre panier est vide."
     return
   end

   begin
     session = Stripe::Checkout::Session.create(
       payment_method_types: ['card'],
       line_items: cart.items.map do |item|
         {
           price_data: {
             currency: 'eur',
             product_data: {
               name: item.title,
               description: item.description
             },
             unit_amount: (item.price.to_f * 100).round
           },
           quantity: 1
         }
       end,
       mode: 'payment',
       success_url: request.base_url + "/order/success",
       cancel_url: request.base_url + "/cart"
     )

     redirect_to session.url, allow_other_host: true
   rescue Stripe::StripeError => e
     redirect_to cart_path, alert: "Erreur lors de la création du paiement: #{e.message}"
   rescue => e
     Rails.logger.error "Erreur checkout: #{e.message}"
     Rails.logger.error e.backtrace.join("\n")
     redirect_to cart_path, alert: "Une erreur inattendue s'est produite. Veuillez réessayer."
   end
 end

end