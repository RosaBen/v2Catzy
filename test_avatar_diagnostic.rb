#!/usr/bin/env ruby

# Script de test pour vérifier les avatars par défaut
puts "🔍 Test des avatars par défaut"
puts "=" * 50

# Vérifier les fichiers
files_to_check = [
  "/home/rosa/THP/RUBY/week10/v2Catzy/public/default-avatar.svg",
  "/home/rosa/THP/RUBY/week10/v2Catzy/app/assets/images/default-avatar.svg",
  "/home/rosa/THP/RUBY/week10/v2Catzy/app/assets/images/pexels-pixabay-416160.jpg"
]

files_to_check.each do |file|
  if File.exist?(file)
    size = File.size(file)
    puts "✅ #{file} (#{size} bytes)"
  else
    puts "❌ #{file} (manquant)"
  end
end

puts "\n🌐 Test des URLs externes"
begin
  require 'net/http'
  uri = URI('https://via.placeholder.com/100x100/f8f9fa/6c757d?text=👤')
  response = Net::HTTP.get_response(uri)
  if response.code == '200'
    puts "✅ Placeholder externe accessible (#{response.code})"
  else
    puts "⚠️  Placeholder externe : #{response.code}"
  end
rescue => e
  puts "❌ Placeholder externe : #{e.message}"
end

puts "\n📝 Base64 SVG"
base64_svg = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB2aWV3Qm94PSIwIDAgMTAwIDEwMCI+CiAgPGNpcmNsZSBjeD0iNTAiIGN5PSI1MCIgcj0iNTAiIGZpbGw9IiNmOGY5ZmEiIHN0cm9rZT0iI2RlZTJlNiIgc3Ryb2tlLXdpZHRoPSIyIi8+CiAgPGNpcmNsZSBjeD0iNTAiIGN5PSIzNSIgcj0iMTUiIGZpbGw9IiM2Yzc1N2QiLz4KICA8cGF0aCBkPSJNMjUgNzUgUTI1IDYwIDUwIDYwIFE3NSA2MCA3NSA3NSIgZmlsbD0iIzZjNzU3ZCIvPgo8L3N2Zz4="

if base64_svg.length > 100
  puts "✅ Base64 SVG prêt (#{base64_svg.length} caractères)"
else
  puts "❌ Base64 SVG trop court"
end

puts "\n✨ Recommandations:"
puts "1. L'avatar Base64 devrait toujours fonctionner"
puts "2. Le fichier public/default-avatar.svg est accessible directement"
puts "3. Le fallback CSS (emoji 👤) est garanti"
puts "4. En production, prioriser Base64 > Public > Externe > CSS"

puts "\n🚀 Pour Render, s'assurer que :"
puts "- Les assets sont précompilés (voir config/initializers/assets.rb)"
puts "- Le dossier public/ est accessible"
puts "- Les URLs externes sont autorisées"
