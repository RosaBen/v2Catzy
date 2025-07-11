class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :orders, dependent: :destroy
  has_one :cart, dependent: :destroy
  has_one_attached :avatar

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Validations plus souples pour éviter les erreurs lors des mises à jour
  validates :first_name, length: { maximum: 50 }, allow_blank: true
  validates :last_name, length: { maximum: 50 }, allow_blank: true
  validates :email, presence: true, uniqueness: true
  # Devise s'occupe déjà de la validation du password

  def fullname
    "#{first_name} #{last_name}".strip.presence || "Utilisateur"
  end
end
