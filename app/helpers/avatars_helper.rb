module AvatarsHelper
  def user_avatar(user, options = {})
    css_class = options[:class] || "avatar-profil"
    
    begin
      if user&.avatar&.attached?
        image_tag url_for(user.avatar), alt: "Avatar utilisateur", class: css_class
      else
        render_default_avatar(css_class)
      end
    rescue => e
      Rails.logger.error "❌ Erreur avatar helper: #{e.message}"
      ultimate_fallback_avatar(css_class)
    end
  end

  private

  def render_default_avatar(css_class)
    Rails.logger.info "🎭 Render default avatar - Environment: #{Rails.env}"
    
    # PRIORITÉ 1: Base64 intégré (toujours disponible, ne dépend d'aucun fichier)
    begin
      base64_svg = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB2aWV3Qm94PSIwIDAgMTAwIDEwMCI+CiAgPGNpcmNsZSBjeD0iNTAiIGN5PSI1MCIgcj0iNTAiIGZpbGw9IiNmOGY5ZmEiIHN0cm9rZT0iI2RlZTJlNiIgc3Ryb2tlLXdpZHRoPSIyIi8+CiAgPGNpcmNsZSBjeD0iNTAiIGN5PSIzNSIgcj0iMTUiIGZpbGw9IiM2Yzc1N2QiLz4KICA8cGF0aCBkPSJNMjUgNzUgUTI1IDYwIDUwIDYwIFE3NSA2MCA3NSA3NSIgZmlsbD0iIzZjNzU3ZCIvPgo8L3N2Zz4="
      Rails.logger.info "✅ Using Base64 SVG avatar"
      return image_tag base64_svg, alt: "Avatar par défaut", class: css_class
    rescue => e
      Rails.logger.error "❌ Base64 SVG avatar failed: #{e.message}"
    end

    # PRIORITÉ 2: SVG dans public/ (accessible directement via URL)
    begin
      Rails.logger.info "🔄 Trying public SVG avatar"
      return image_tag "/default-avatar.svg", alt: "Avatar par défaut", class: css_class
    rescue => e
      Rails.logger.error "❌ Public SVG avatar failed: #{e.message}"
    end

    # PRIORITÉ 3: Assets Rails (peut échouer en production selon la config)
    unless Rails.env.production?
      begin
        Rails.logger.info "🔄 Trying Rails assets avatar"
        return image_tag "default-avatar.svg", alt: "Avatar par défaut", class: css_class
      rescue => e
        Rails.logger.debug "Assets SVG avatar failed: #{e.message}"
      end
    end

    # PRIORITÉ 4: Fallback ultime garanti
    Rails.logger.warn "⚠️ All image options failed, using CSS fallback"
    ultimate_fallback_avatar(css_class)
  end

  def ultimate_fallback_avatar(css_class)
    # CSS pur avec emoji - toujours disponible
    content_tag :div, "👤", 
                class: "#{css_class} bg-light border rounded-circle d-flex align-items-center justify-content-center", 
                style: "font-size: 2em; width: 60px; height: 60px; min-width: 60px; min-height: 60px; color: #6c757d;"
  end
end