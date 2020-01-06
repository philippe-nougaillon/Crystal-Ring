class Facture < ApplicationRecord
  include WorkflowActiverecord

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  audited 

  has_one_attached :scan

  has_many :cibles, inverse_of: :facture, dependent: :delete_all
  has_associated_audits
  accepts_nested_attributes_for :cibles, reject_if: proc { |attributes| attributes[:email].blank? }, allow_destroy: true

  validates :etat, :anomalie, :société, :num_chrono, presence: true

  default_scope { order(Arel.sql("factures.updated_at DESC")) }

  enum anomalie: [:po, :contrat, :montant, :réception, :inconnu]

  self.per_page = 10


  enum etat: [:ajoutée, :envoyée, :ring1, :ring2, :ring3, :validée, :rejetée, :imputée]
  
  AJOUTEE = 'ajoutée'
  ENVOYEE = 'envoyée'
  RING1   = 'ring1'
  RING2   = 'ring2'
  RING3   = 'ring3'
  VALIDEE = 'validée'
  REJETEE = 'rejetée'
  IMPUTEE = 'imputée'

  workflow do
    state AJOUTEE do
      event :envoyer, transitions_to: ENVOYEE
    end

    state ENVOYEE do
      event :valider, transitions_to: VALIDEE
      event :rejeter, transitions_to: REJETEE
      event :relancer, transitions_to: RING2
    end

    state RING2 do
      event :valider, transitions_to: VALIDEE
      event :rejeter, transitions_to: REJETEE
      event :relancer, transitions_to: RING3
    end

    state RING3 do
      event :valider, transitions_to: VALIDEE
      event :rejeter, transitions_to: REJETEE
    end

    state VALIDEE do
      event :imputer, transitions_to: IMPUTEE
    end

    state REJETEE

    state IMPUTEE

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
      self.anomalie = 0
    end
  end

  def self.styles
    ['badge-info','badge-warning','badge-secondary','badge-secondary','badge-secondary','badge-success','badge-danger','badge-dark']
  end

  def style
    Facture.styles[Facture.etats[self.etat]]
  end

  def self.etats_capitalized
    self.etats.map {|k, v| [k.humanize.capitalize, v]}
  end

  def self.anomalies_capitalized
    self.anomalies.map {|k, v| [k.humanize.capitalize, v]}
  end 

  def les_cibles
    cibles = []
    self.cibles.each do |c| 
      cibles << c.email + (!c.commentaires.blank? ?  " => #{c.commentaires}" : '')
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
        f.etat.humanize, 
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
