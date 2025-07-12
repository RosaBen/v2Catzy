#!/usr/bin/env ruby

require_relative 'config/environment'

puts "🗑️  Script de suppression des avatars"
puts "=" * 50

users_with_avatars = User.joins(:avatar_attachment)
puts "👥 Utilisateurs avec avatar : #{users_with_avatars.count}"

if users_with_avatars.any?
  puts "\nUtilisateurs :"
  users_with_avatars.each do |user|
    puts "- #{user.email} (ID: #{user.id})"
  end
  
  puts "\n❓ Voulez-vous supprimer tous les avatars ? (oui/non)"
  # En production, vous devriez demander confirmation
  # response = gets.chomp.downcase
  
  # Pour ce script de debug, on va juste les lister
  puts "\n📋 Pour supprimer manuellement :"
  puts "User.find(#{users_with_avatars.first.id}).avatar.purge  # Supprimer l'avatar du premier utilisateur"
  puts "User.all.each { |u| u.avatar.purge if u.avatar.attached? }  # Supprimer tous les avatars"
  
else
  puts "✅ Aucun utilisateur n'a d'avatar attaché"
end

puts "\n🧪 Test de l'avatar par défaut :"
test_user = User.first
if test_user
  puts "Utilisateur de test : #{test_user.email}"
  puts "Avatar attaché ? #{test_user.avatar.attached?}"
  
  if test_user.avatar.attached?
    puts "🔧 Pour tester l'avatar par défaut, exécutez :"
    puts "User.find(#{test_user.id}).avatar.purge"
  else
    puts "✅ Cet utilisateur utilise l'avatar par défaut"
  end
end
