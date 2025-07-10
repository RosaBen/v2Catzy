Rails.application.routes.draw do
  get "orders/success"
  get "carts/show"
  get "cart_items/create"
  devise_for :users

  root to: "items#index"

  resources :items
  resource :profil
  resources :avatars, only: [ :create, :update, :destroy ]
  resource :cart, only: [:show]
  resources :cart_items, only: [:create]
  delete "cart_items/remove/:item_id", to: "cart_items#destroy", as: :remove_cart_item


post "checkout/create", to: "checkout#create", as: :checkout_create
post "checkout/cart", to: "checkout#create_cart_checkout", as: :checkout_cart

get "order/success", to: "orders#success", as: :order_success

end