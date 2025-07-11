module ApplicationHelper
  def stripe_publishable_key
    Rails.configuration.stripe[:publishable_key]
  end
end
