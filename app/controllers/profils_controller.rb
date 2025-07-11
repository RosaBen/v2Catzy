class ProfilsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
  end

  def show
    @user = current_user
    begin
      # Traiter les commandes en attente s'il y en a
      PendingOrderService.process_pending_orders_for_user(current_user)
      
      # Charger les commandes
      @orders = current_user.orders.includes(:order_items => :item).order(created_at: :desc)
      Rails.logger.info "✅ Chargement de #{@orders.count} commandes pour utilisateur #{current_user.id}"
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
      # Nettoyer les paramètres avant la mise à jour
      user_update_params = user_params.to_h
      
      # Supprimer les champs vides pour éviter les erreurs de validation
      user_update_params.delete_if { |key, value| value.blank? && key != 'avatar' }
      
      # Si l'email est modifié, vérifier qu'il soit valide
      if user_update_params['email'].present? && user_update_params['email'] != @user.email
        if User.where(email: user_update_params['email']).where.not(id: @user.id).exists?
          flash.now[:alert] = "Cet email est déjà utilisé par un autre compte."
          render :edit, status: :unprocessable_entity
          return
        end
      end

      if @user.update(user_update_params)
        flash[:notice] = if params[:user][:avatar].present?
          "Profil et avatar mis à jour avec succès!"
        else
          "Profil mis à jour avec succès!"
        end
        
        # Redirection avec succès
        redirect_to profil_path and return
      else
        # Erreurs de validation
        error_messages = @user.errors.full_messages
        Rails.logger.warn "❌ Erreurs validation profil utilisateur #{@user.id}: #{error_messages.join(', ')}"
        
        flash.now[:alert] = "Erreur lors de la mise à jour : #{error_messages.join(', ')}"
        render :edit, status: :unprocessable_entity
      end
      
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "❌ Erreur validation profil: #{e.message}"
      flash.now[:alert] = "Erreur de validation : #{e.message}"
      render :edit, status: :unprocessable_entity
      
    rescue => e
      Rails.logger.error "❌ Erreur lors de la mise à jour du profil utilisateur #{current_user.id}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      flash.now[:alert] = "Une erreur inattendue s'est produite. Veuillez réessayer."
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