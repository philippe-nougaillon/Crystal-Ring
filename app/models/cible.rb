class Cible < ApplicationRecord
  belongs_to :facture
  audited associated_with: :facture
end
