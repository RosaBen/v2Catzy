module AvatarsHelper
  def user_avatar(user, options = {})
    default_options = { alt: "Avatar de #{user.fullname}" }
    options = default_options.merge(options)

    if user.avatar.attached?
      image_tag url_for(user.avatar), options
    else
      image_tag "pexels-pixabay-416160.jpg", options.merge(alt: "Avatar par défaut", style: "width: 50px; height: auto;")
    end
  rescue
    image_tag "https://img.freepik.com/photos-gratuite/avatar-androgyne-personne-queer-non-binaire_23-2151100205.jpg", options.merge(alt: "Avatar par défaut", style: "width: 50px; height: auto;")
  end
end