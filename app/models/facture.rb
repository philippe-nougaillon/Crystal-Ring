class Facture < ApplicationRecord
  audited

  enum etat: [:ajoutée, :envoyée, :validée, :rejetée]
  enum anomalie: [:po, :contrat, :montant, :réception, :inconnu]

  validates :etat, :anomalie, :société, :num_chrono, :cible, presence: true

  has_one_attached :scan

  after_initialize do
    if self.new_record?
      self.etat = 0
      self.anomalie = 0
    end
  end

  default_scope { order(Arel.sql("factures.updated_at DESC")) }

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged


  def self.styles
    ['badge-info','badge-warning','badge-success','badge-danger']
  end

  def style
    Facture.styles[Facture.etats[self.etat]]
  end

private
  # only one candidate for an nice id; one random UDID
  def slug_candidates
    [SecureRandom.uuid]
  end

end
