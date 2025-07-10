class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :orders, dependent: :destroy
  has_one :cart, dependent: :destroy
  has_one_attached :avatar

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # validates :first_name, presence: true
  # validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :encrypted_password, presence: true, length: { minimum: 6 }

  def fullname
    "#{first_name} #{last_name}".strip
  end
end
