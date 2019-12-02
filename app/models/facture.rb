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

    extend FriendlyId
    # friendly_id :num_chrono, use: :slugged
    friendly_id :slug_candidates, use: :slugged

private
  # only one candidate for an nice id; one random UDID
  def slug_candidates
    [SecureRandom.uuid]
  end

end
