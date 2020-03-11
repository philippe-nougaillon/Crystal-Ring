class Facture < ApplicationRecord
  include WorkflowActiverecord

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  audited 

  has_one_attached :scan

  has_many :cibles, inverse_of: :facture, dependent: :delete_all
  has_associated_audits
  accepts_nested_attributes_for :cibles, reject_if: proc { |attributes| attributes[:email].blank? }, allow_destroy: true
  
  validates :anomalie, :société, :num_chrono, presence: true
  validates_uniqueness_of :num_chrono

  default_scope { order(Arel.sql("factures.updated_at DESC")) }

  enum anomalie: [:manque_po, :manque_contrat, :écart_valeur, :manque_réception, :inconnu]

  self.per_page = 10
  
  AJOUTEE = 'ajoutée'
  ENVOYEE = 'envoyée'
  RING1   = 'ring1'
  RING2   = 'ring2'
  RING3   = 'ring3'
  VALIDEE = 'validée'
  REJETEE = 'rejetée'
  IMPUTEE = 'imputée'

  workflow do
    state AJOUTEE, meta: {style: 'badge-info'} do
      event :envoyer, transitions_to: ENVOYEE
    end

    state ENVOYEE, meta: {style: 'badge-warning'} do
      event :valider, transitions_to: VALIDEE
      event :rejeter, transitions_to: REJETEE
      event :relancer, transitions_to: RING1
    end

    state RING1, meta: {style: 'badge-secondary'} do
      event :valider, transitions_to: VALIDEE
      event :rejeter, transitions_to: REJETEE
      event :relancer, transitions_to: RING2
    end

    state RING2, meta: {style: 'badge-secondary'} do
      event :valider, transitions_to: VALIDEE
      event :rejeter, transitions_to: REJETEE
      event :relancer, transitions_to: RING3
    end

    state RING3, meta: {style: 'badge-secondary'} do
      event :valider, transitions_to: VALIDEE
      event :rejeter, transitions_to: REJETEE
      event :relancer, transitions_to: RING1
    end

    state VALIDEE, meta: {style: 'badge-success'} do
      event :imputer, transitions_to: IMPUTEE
    end

    state REJETEE, meta: {style: 'badge-danger'}

    state IMPUTEE, meta: {style: 'badge-dark'}

    after_transition do |from, to, triggering_event, *event_args|
      logger.debug "[WORKFLOW] #{from} -> #{to} #{triggering_event}"
    end
  end

  # pour que le changement se voit dans l'audit trail
  def persist_workflow_state(new_value)
    self[:workflow_state] = new_value
    save!
  end

  after_initialize do
    if self.new_record?
      self.etat = 0
    end
  end

  def style
    self.current_state.meta[:style]
  end

  def self.anomalies_capitalized
    self.anomalies.map {|k, v| [k.humanize.capitalize, v]}
  end 

  def self.workflow_states_capitalized
    self.workflow_spec.state_names.map {|k| [k.to_s.humanize.capitalize]}
  end 

  def les_cibles
    cibles = []
    self.cibles.each do |c| 
      cibles << c.email.split('@').first
                  .concat(!c.réponse.blank? ? " -> #{c.réponse}": '') 
                  .concat(!c.commentaires.blank? ?  " ('#{c.commentaires}')" : '')
    end
    cibles.join(' | ')
  end

  def validable?
    self.current_state < :validée
  end  

  def self.xls_headers
		%w{Id Etat Anomalie Num_chrono Par Société Cible Slug MontantHT Commentaires Created_at Updated_at}
  end
  
  def self.to_xls(factures)
    require 'spreadsheet'    
		
		Spreadsheet.client_encoding = 'UTF-8'
	
		book = Spreadsheet::Workbook.new
		sheet = book.create_worksheet name: 'Factures'
		bold = Spreadsheet::Format.new :weight => :bold, :size => 10
	
		sheet.row(0).concat Facture.xls_headers
		sheet.row(0).default_format = bold
    

		index = 1
		factures.each do |f|
			fields_to_export = [
        f.id, 
        f.workflow_state, 
        f.anomalie.humanize, 
        f.num_chrono, 
        f.par, 
        f.société, 
        f.les_cibles, 
        f.slug, 
        f.montantHT.to_f, 
        f.commentaires, 
        f.created_at, 
				f.updated_at
			]
			sheet.row(index).replace fields_to_export
			index += 1
		end
	
		return book

  end

  def self.relancer(factures)
    # Envoyer à nouveau (relance) vers la première cible
    
    factures.each do |f| 
      if f.current_state.between? :envoyée, :ring3 
        if destinataire = f.cibles.where(repondu_le: nil).first 
          FactureMailer.with(cible: destinataire).notification_email.deliver_later
          destinataire.update!(envoyé_le: DateTime.now)
          f.relancer!
        end
      end
    end
  end


private
  # only one candidate for an nice id; one random UDID
  def slug_candidates
    [SecureRandom.uuid]
  end

  def cibles_opérateur_unique
    if cibles.pluck(:opérateur).count > 1
      errors.add(:base, "opérateur doit être unique !")
    end
  end

end
