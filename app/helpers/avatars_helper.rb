module AvatarsHelper
  def user_avatar(user, options = {})
    # Simplification maximale pour éviter les erreurs
    css_class = options[:class] || "avatar-profil"
    
    begin
      if user&.avatar&.attached?
        image_tag url_for(user.avatar), alt: "Avatar utilisateur", class: css_class
      else
        # Utiliser directement l'image par défaut
        image_tag "pexels-pixabay-416160.jpg", alt: "Avatar par défaut", class: css_class
      end
    rescue => e
      # Fallback simple en cas d'erreur
      content_tag :div, "👤", class: "#{css_class} text-center", style: "font-size: 2em;"
    end
  end
end