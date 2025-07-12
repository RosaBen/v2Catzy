#!/usr/bin/env ruby

require_relative 'config/environment'

puts "🧪 Test de la route remove_avatar"
puts "=" * 50

# Vérifier que l'action existe
if ProfilsController.method_defined?(:remove_avatar)
  puts "✅ Méthode remove_avatar existe dans ProfilsController"
else
  puts "❌ Méthode remove_avatar manquante dans ProfilsController"
end

# Vérifier les routes
routes_output = `cd #{Rails.root} && rails routes | grep remove_avatar`
if routes_output.include?("remove_avatar")
  puts "✅ Route remove_avatar trouvée :"
  puts routes_output
else
  puts "❌ Route remove_avatar non trouvée"
end

# Vérifier un utilisateur avec avatar
user_with_avatar = User.joins(:avatar_attachment).first
if user_with_avatar
  puts "\n👤 Utilisateur avec avatar trouvé :"
  puts "- Email: #{user_with_avatar.email}"
  puts "- Avatar attaché: #{user_with_avatar.avatar.attached?}"
  
  puts "\n🔧 Pour tester manuellement :"
  puts "User.find(#{user_with_avatar.id}).avatar.purge"
else
  puts "\n⚠️ Aucun utilisateur avec avatar trouvé"
end

puts "\n📋 URLs de test :"
puts "- Page profil: https://v2catzy.onrender.com/profil"
puts "- Test route: https://v2catzy.onrender.com/test-route-avatar.html"

puts "\n🐛 Si erreur 404 persiste :"
puts "1. Vérifiez que vous êtes connecté"
puts "2. Redémarrez l'application sur Render"
puts "3. Vérifiez les logs Render pour voir si l'action est appelée"
