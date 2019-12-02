class Facture < ApplicationRecord
    audited

    enum etat: [:ajoutée, :envoyée, :validée, :rejetée]
    enum anomalie: [:po, :contrat, :montant, :réception, :inconnu]

    validates :etat, :anomalie, :société, :num_chrono, :cible, presence: true

    has_one_attached :scan

    after_initialize do
        if self.new_record?
          # values will be available for new record forms.
          self.etat = 0
          self.anomalie = 0
        end
    end

    extend FriendlyId
    friendly_id :num_chrono, use: :slugged

end
