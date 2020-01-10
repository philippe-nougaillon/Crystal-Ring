class Cible < ApplicationRecord
  belongs_to :facture
  audited associated_with: :facture

  default_scope { order(Arel.sql("cibles.id")) } 

  scope :sans_réponse, -> { where(repondu_le: nil) }

end
