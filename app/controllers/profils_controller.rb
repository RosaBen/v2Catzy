class ProfilsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
  end

  def show
    @user = current_user
    @orders = current_user.orders.includes(:order_items => :item).order(created_at: :desc)
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    begin
      if @user.update(user_params)
        if params[:user][:avatar].present?
          flash[:notice] = "Profil et avatar mis à jour avec succès!"
        else
          flash[:notice] = "Profil mis à jour avec succès!"
        end
        redirect_to profil_path
      else
        flash.now[:alert] = "Erreur lors de la mise à jour du profil: #{@user.errors.full_messages.join(', ')}"
        render :edit, status: :unprocessable_entity
      end
    rescue => e
      Rails.logger.error "Erreur lors de la mise à jour du profil: #{e.message}"
      flash.now[:alert] = "Une erreur est survenue lors de la mise à jour du profil."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user = current_user
    
    # Vérifier si l'utilisateur a des commandes
    if @user.orders.exists?
      flash[:alert] = "Impossible de supprimer votre compte car vous avez des commandes en cours. Contactez le support."
      redirect_to edit_user_registration_path
    else
      @user.destroy
      reset_session  
      flash[:notice] = "Compte supprimé avec succès."
      redirect_to root_path
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :avatar)
  end
end