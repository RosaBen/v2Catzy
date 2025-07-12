# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Précompiler les images utilisées comme avatars par défaut
Rails.application.config.assets.precompile += %w[
  default-avatar.svg
  pexels-pixabay-416160.jpg
  cat-2083492_960_720.jpg
  hero-image.jpg
]
