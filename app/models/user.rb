class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable, :token_authenticatable
  has_many :tweets
  has_many :follows
  has_many :followers, through: :follows
  has_many :inverse_followers, class_name: "Follow", :foreign_key => :follower_id
  has_many :following, through: :inverse_followers, source: :user 
end
