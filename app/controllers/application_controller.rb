class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :configure_devise_parameters, if: :devise_controller?
  helper_method :current_cart

def configure_devise_parameters
  devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:first_name, :last_name, :avatar, :email, :password, :password_confirmation) }
  devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:first_name, :last_name, :avatar, :email, :password, :password_confirmation) }
end

def current_cart
  if user_signed_in?
    current_user.cart || current_user.create_cart
  else
    Cart.find(session[:cart_id])
  end
rescue ActiveRecord::RecordNotFound
  cart = Cart.create
  session[:cart_id] = cart.id
  cart
end
end
