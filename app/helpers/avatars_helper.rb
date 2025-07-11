module AvatarsHelper
  def user_avatar(user, options = {})
    default_options = { alt: "Avatar de #{user.fullname}" }
    options = default_options.merge(options)

    if user.avatar.attached?
      begin
        image_tag url_for(user.avatar), options
      rescue => e
        Rails.logger.warn "❌ Erreur chargement avatar utilisateur #{user.id}: #{e.message}"
        # Fallback vers avatar par défaut
        image_tag "pexels-pixabay-416160.jpg", options.merge(alt: "Avatar par défaut")
      end
    else
      # Avatar par défaut - essayer d'abord l'asset local
      begin
        image_tag "pexels-pixabay-416160.jpg", options.merge(alt: "Avatar par défaut")
      rescue => e
        Rails.logger.warn "❌ Image par défaut introuvable: #{e.message}"
        # Fallback vers une image externe
        image_tag "https://img.freepik.com/photos-gratuite/avatar-androgyne-personne-queer-non-binaire_23-2151100205.jpg", 
                  options.merge(alt: "Avatar par défaut", style: "width: 50px; height: auto;")
      end
    end
  rescue => e
    Rails.logger.error "❌ Erreur critique avatar helper: #{e.message}"
    # Fallback ultime
    content_tag :div, "👤", class: "avatar-fallback #{options[:class]}", style: "font-size: 2em; text-align: center;"
  end
end