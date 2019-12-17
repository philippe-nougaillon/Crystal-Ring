class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, #:registerable,
         :recoverable, :rememberable, :validatable

  audited

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged


private
    # only one candidate for an nice id; one random UDID
    def slug_candidates
      [SecureRandom.uuid]
    end

end
