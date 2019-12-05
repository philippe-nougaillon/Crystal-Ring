class Facture < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  audited 

  has_one_attached :scan

  has_many :cibles, inverse_of: :facture, dependent: :delete_all
  has_associated_audits
  accepts_nested_attributes_for :cibles, reject_if: proc { |attributes| attributes[:email].blank? }, allow_destroy: true

  validates :etat, :anomalie, :société, :num_chrono, presence: true

  default_scope { order(Arel.sql("factures.updated_at DESC")) }

  enum etat: [:ajoutée, :envoyée, :ring1, :ring2, :ring3, :validée, :rejetée, :imputée]
  enum anomalie: [:po, :contrat, :montant, :réception, :inconnu]

  self.per_page = 10

  after_initialize do
    if self.new_record?
      self.etat = 0
      self.anomalie = 0
    end
  end

  def self.styles
    ['badge-info','badge-warning','badge-secondary','badge-secondary','badge-secondary','badge-success','badge-danger','badge-dark']
  end

  def style
    Facture.styles[Facture.etats[self.etat]]
  end

  def les_cibles
    self.cibles.pluck(:opérateur, :email).join(' ')
  end

private
  # only one candidate for an nice id; one random UDID
  def slug_candidates
    [SecureRandom.uuid]
  end

end
