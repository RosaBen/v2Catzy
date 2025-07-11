# Configuration Stripe avec gestion d'erreurs
begin
  Rails.configuration.stripe = {
    publishable_key: ENV["STRIPE_PUBLIC_KEY"] || ENV["STRIPE_PUBLISHABLE_KEY"],
    secret_key: ENV["STRIPE_SECRET_KEY"]
  }

  # Vérifier que les clés sont présentes
  if Rails.configuration.stripe[:secret_key].blank?
    Rails.logger.error "❌ STRIPE_SECRET_KEY non configurée!"
    if Rails.env.production?
      raise "Configuration Stripe manquante en production"
    end
  else
    Stripe.api_key = Rails.configuration.stripe[:secret_key]
    Rails.logger.info "✅ Stripe configuré avec succès (#{Rails.env})"
  end

rescue => e
  Rails.logger.error "❌ Erreur configuration Stripe: #{e.message}"
  raise e if Rails.env.production?
end