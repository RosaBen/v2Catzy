class ProfilsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
  end

  def show
    @user = current_user
    
    # Version ultra-simplifiée pour éviter les erreurs
    begin
      @orders = current_user.orders.order(created_at: :desc)
    rescue => e
      Rails.logger.error "❌ Erreur chargement commandes: #{e.message}"
      @orders = []
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    begin
      # Gérer la suppression d'avatar si demandée
      if params[:remove_avatar] == 'true'
        Rails.logger.info "🗑️ Avatar removal requested via update"
        if @user.avatar.attached?
          @user.avatar.purge
          flash[:notice] = "Avatar supprimé avec succès!"
        else
          flash[:alert] = "Aucun avatar à supprimer."
        end
        redirect_to profil_path
        return
      end

      if @user.update(user_params)
        flash[:notice] = "Profil mis à jour avec succès!"
        redirect_to profil_path
      else
        flash.now[:alert] = "Erreur lors de la mise à jour du profil."
        render :edit, status: :unprocessable_entity
      end
    rescue => e
      Rails.logger.error "❌ Erreur mise à jour profil: #{e.message}"
      flash.now[:alert] = "Une erreur s'est produite lors de la mise à jour."
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

  def remove_avatar
    Rails.logger.info "🗑️ remove_avatar action called for user: #{current_user&.email}"
    @user = current_user
    
    begin
      if @user.avatar.attached?
        Rails.logger.info "✅ Avatar found, purging..."
        @user.avatar.purge
        flash[:notice] = "Avatar supprimé avec succès!"
        Rails.logger.info "✅ Avatar purged successfully"
      else
        Rails.logger.warn "⚠️ No avatar to remove"
        flash[:alert] = "Aucun avatar à supprimer."
      end
    rescue => e
      Rails.logger.error "❌ Erreur suppression avatar: #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")
      flash[:alert] = "Erreur lors de la suppression de l'avatar."
    end
    
    redirect_to profil_path
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :avatar)
  end
end