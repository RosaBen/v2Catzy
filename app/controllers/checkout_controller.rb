class CheckoutController < ApplicationController
  before_action :authenticate_user!

 def create
   item = Item.find(params[:item_id])

   session = Stripe::Checkout::Session.create(
     payment_method_types: [ "card" ],
     line_items: [ {
       price_data: {
         currency: "eur",
         product_data: {
           name: item.title
         },
         unit_amount: (item.price * 100).to_i
       },
       quantity: 1
     } ],
     mode: "payment",
     success_url: root_url + "?success=true",
     cancel_url: root_url + "?canceled=true",
   )

   redirect_to session.url, allow_other_host: true
 end

 def create_cart_checkout
 cart = current_cart

 if cart.blank? || cart.items.empty?
   redirect_to cart_path, alert: "Votre panier est vide."
   return
 end

 session = Stripe::Checkout::Session.create(
   payment_method_types: ['card'],
   line_items: cart.items.map do |item|
     {
       price_data: {
         currency: 'eur',
         product_data: {
           name: item.title
         },
         unit_amount: (item.price.to_f * 100).round
       },
       quantity: 1
     }
   end,
   mode: 'payment',
   success_url: order_success_url,
   cancel_url: cart_url
 )

 redirect_to session.url, allow_other_host: true
end

end