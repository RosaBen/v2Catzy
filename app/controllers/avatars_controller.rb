class AvatarsController < ApplicationController
  before_action :authenticate_user!

  def create
    if params[:avatar].present?
      current_user.avatar.attach(params[:avatar])
      flash[:notice] = "Avatar mis à jour avec succès!"
      redirect_to profil_path
    else
      flash[:alert] = "Veuillez sélectionner un fichier."
      redirect_to profil_path
    end
  end
end