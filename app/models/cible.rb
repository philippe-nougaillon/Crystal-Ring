class Cible < ApplicationRecord
  belongs_to :facture
  audited associated_with: :facture

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  default_scope { order(Arel.sql("cibles.id")) } 

  scope :sans_réponse, -> { where(repondu_le: nil) }

private

  # only one candidate for an nice id; one random UDID
  def slug_candidates
    [SecureRandom.uuid]
  end

end
