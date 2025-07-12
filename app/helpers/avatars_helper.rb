module AvatarsHelper
  def user_avatar(user, options = {})
    css_class = options[:class] || "avatar-profil"
    
    if user&.avatar&.attached?
      begin
        image_tag url_for(user.avatar), alt: "Avatar utilisateur", class: css_class
      rescue => e
        Rails.logger.error "❌ User avatar failed: #{e.message}"
        default_avatar_guaranteed(css_class)
      end
    else
      default_avatar_guaranteed(css_class)
    end
  end

  private

  def default_avatar_guaranteed(css_class)
    Rails.logger.info "🎭 Generating default avatar for #{Rails.env}"
    
    # OPTION 1: SVG simple dans public/ - Marche toujours sur Render
    if avatar_file_exists?("/avatar.svg")
      Rails.logger.info "✅ Using public SVG avatar"
      return image_tag "/avatar.svg", alt: "Avatar", class: css_class, 
                      style: "width: 60px; height: 60px; border-radius: 50%; object-fit: cover;"
    end

    # OPTION 2: Base64 intégré - Ne peut jamais échouer
    Rails.logger.info "✅ Using guaranteed Base64 SVG avatar"
    base64_avatar = "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI2MCIgaGVpZ2h0PSI2MCIgdmlld0JveD0iMCAwIDYwIDYwIj48Y2lyY2xlIGN4PSIzMCIgY3k9IjMwIiByPSIyOCIgZmlsbD0iI2U5ZWNlZiIgc3Ryb2tlPSIjZGVlMmU2IiBzdHJva2Utd2lkdGg9IjIiLz48Y2lyY2xlIGN4PSIzMCIgY3k9IjIyIiByPSI4IiBmaWxsPSIjNmM3NTdkIi8+PGVsbGlwc2UgY3g9IjMwIiBjeT0iNDIiIHJ4PSIxMiIgcnk9IjgiIGZpbGw9IiM2Yzc1N2QiLz48L3N2Zz4K"
    
    begin
      image_tag base64_avatar, alt: "Avatar", class: css_class, 
                style: "width: 60px; height: 60px; border-radius: 50%; object-fit: cover;"
    rescue => e
      Rails.logger.error "❌ Even Base64 failed: #{e.message}"
      # ULTIME FALLBACK: CSS pur - impossible à échouer
      content_tag :div, "", 
                  class: "#{css_class} bg-secondary rounded-circle", 
                  style: "width: 60px; height: 60px; border: 2px solid #6c757d; flex-shrink: 0;"
    end
  end

  def avatar_file_exists?(path)
    begin
      full_path = Rails.root.join("public#{path}")
      File.exist?(full_path) && File.size(full_path) > 0
    rescue
      false
    end
  end
end