class Facture < ApplicationRecord
    audited

    enum etat: [:ajoutée, :envoyée, :validée, :rejetée]
    enum anomalie: [:po, :contrat, :montant, :réception, :inconnu]

    validates :etat, :anomalie, :société, :num_chrono, :cible, presence: true
end
