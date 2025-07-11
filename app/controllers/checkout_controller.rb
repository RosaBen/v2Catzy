class CheckoutController < ApplicationController
  before_action :authenticate_user!

 def create
   item = Item.find(params[:item_id])

   begin
     # Stocker les informations pour créer l'order après le paiement
     session[:checkout_cart_id] = nil # Pas de panier pour achat direct
     session[:checkout_total_amount] = (item.price * 100).to_i # En centimes pour Stripe
     session[:checkout_items] = [{ id: item.id, price: item.price, title: item.title }]

     stripe_session = Stripe::Checkout::Session.create(
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
       success_url: request.base_url + "/order/success",
       cancel_url: request.base_url + "/items/#{item.id}",
     )

     redirect_to stripe_session.url, allow_other_host: true
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

   # Vérifier la configuration Stripe
   unless Stripe.api_key.present?
     Rails.logger.error "❌ Clé API Stripe manquante lors du checkout"
     redirect_to cart_path, alert: "Configuration de paiement manquante. Contactez l'administrateur."
     return
   end

   begin
     # Calculer le montant total pour le stocker avec l'order
     total_amount = cart.items.sum(&:price)
     
     # Stocker les informations nécessaires dans la session pour créer l'order après le paiement
     session[:checkout_cart_id] = cart.id
     session[:checkout_total_amount] = (total_amount * 100).round # En centimes pour Stripe
     session[:checkout_items] = cart.items.map { |item| { id: item.id, price: item.price, title: item.title } }

     stripe_session = Stripe::Checkout::Session.create(
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

     redirect_to stripe_session.url, allow_other_host: true
   rescue Stripe::StripeError => e
     Rails.logger.error "❌ Erreur Stripe: #{e.message}"
     redirect_to cart_path, alert: "Erreur lors de la création du paiement: #{e.message}"
   rescue => e
     Rails.logger.error "❌ Erreur checkout: #{e.message}"
     Rails.logger.error e.backtrace.join("\n")
     redirect_to cart_path, alert: "Une erreur inattendue s'est produite. Veuillez réessayer."
   end
 end

end