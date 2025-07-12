#!/usr/bin/env ruby

require_relative 'config/environment'

puts "🧪 Test de l'helper avatar Rails"
puts "=" * 50

# Créer un utilisateur fictif sans avatar
class FakeUser
  def avatar
    nil
  end
end

fake_user = FakeUser.new

# Tester notre helper
include AvatarsHelper

puts "\n🎭 Test du helper user_avatar :"
begin
  result = user_avatar(fake_user, class: "test-avatar")
  puts "✅ Helper fonctionne"
  puts "Résultat : #{result[0..100]}..."
rescue => e
  puts "❌ Helper échoue : #{e.message}"
  puts e.backtrace.first(3)
end

puts "\n📁 Vérification des fichiers :"
files = [
  "public/avatar.svg",
  "public/default-avatar.svg", 
  "app/assets/images/default-avatar.svg"
]

files.each do |file|
  full_path = Rails.root.join(file)
  if File.exist?(full_path)
    puts "✅ #{file} (#{File.size(full_path)} bytes)"
  else
    puts "❌ #{file} manquant"
  end
end

puts "\n🌐 Test de l'URL publique :"
puts "URL de test : http://localhost:3000/avatar.svg"
puts "URL de test : http://localhost:3000/test-avatar.html"

puts "\n💡 Prochaines étapes :"
puts "1. Déployer sur Render"
puts "2. Vérifier les logs avec : heroku logs --tail (ou équivalent Render)"
puts "3. Tester la création d'un compte"
puts "4. L'avatar devrait apparaître avec l'une des options"
