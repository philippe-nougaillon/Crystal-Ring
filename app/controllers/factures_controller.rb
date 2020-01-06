class FacturesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :validation]
  before_action :set_facture, only: [:show, :edit, :update, :destroy]

  # GET /factures
  # GET /factures.json
  def index
    @factures = Facture.all

    unless params[:search].blank?
      s = "%#{params[:search].upcase}%"
      @factures = @factures
                    .joins(:cibles)
                    .where("cibles.email ILIKE ? OR factures.num_chrono::text ILIKE ? OR factures.société ILIKE ? OR factures.par ILIKE ?", s, s, s, s)
                    .distinct
    end

    unless params[:etat].blank?
      @factures = @factures.where("factures.etat = ?", params[:etat])
    end

    unless params[:anomalie].blank?
      @factures = @factures.where("factures.anomalie = ?", params[:anomalie])
    end

    respond_to do |format|
      format.html do
        @factures = @factures.paginate(page: params[:page]).includes(:cibles)
      end

      format.xls do
        book = Facture.to_xls(@factures)
        file_contents = StringIO.new
        book.write file_contents # => Now file_contents contains the rendered file output
        filename = "Factures.xls"
        send_data file_contents.string.force_encoding('binary'), filename: filename 
      end
    end

  end

  # GET /factures/1
  # GET /factures/1.json
  def show

    @pdf_preview = @facture.scan.preview(resize: "827x1170>")

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Facture #{@facture.num_chrono}", 
               encoding: 'UTF-8'
      end
    end

  end

  # GET /factures/new
  def new
    @facture = Facture.new
    5.times { @facture.cibles.build }
  end

  # GET /factures/1/edit
  def edit
    1.times { @facture.cibles.build }
  end

  # POST /factures
  # POST /factures.json
  def create
    @facture = Facture.new(facture_params)

    respond_to do |format|
      if @facture.save

        # Envoyer la notification au premier destinataire
        destinataire = @facture.cibles.first
        FactureMailer.with(cible: destinataire).notification_email.deliver_later(wait: 1.hour)
        destinataire.update!(envoyé_le: DateTime.now)
        @facture.envoyer!

        format.html { redirect_to @facture, notice: 'Facture créée avec succès.' }
        format.json { render :show, status: :created, location: @facture }
      else
        format.html { render :new }
        format.json { render json: @facture.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /factures/1
  # PATCH/PUT /factures/1.json
  def update
    respond_to do |format|
      if @facture.update(facture_params)

        # Envoyer à nouveau (relance) vers toutes les cibles
        if @facture.ring1? || @facture.ring2? || @facture.ring3?
          @facture.cibles.each do |c|
            FactureMailer.with(cible: c).notification_email.deliver_later
            c.update!(envoyé_le: DateTime.now)
          end
        end
    
        format.html { redirect_to @facture, notice: 'Facture modifiée avec succès.' }
        format.json { render :show, status: :ok, location: @facture }
      else
        format.html { render :edit }
        format.json { render json: @facture.errors, status: :unprocessable_entity }
      end
    end
  end

  def validation
    @facture = Facture.find_by(slug: params[:facture_id])
    @pdf_preview = @facture.scan.preview(resize: "827x1170>")

    if action = params[:commit]
      # Marquer ce que la cible a répondu
      @facture.cibles.where(email: params[:email]).each do |c|
        c.update!(repondu_le: DateTime.now, réponse: action, commentaires: params[:commentaires])
      end

      # Si la facture est rejetée, c'est terminé
      if action == "Rejeter"
        @facture.rejeter!
      else
        # sinon on teste s'il y a d'autres destinataires à qui demander une approbation
        if @facture.cibles.where(repondu_le: nil).any?
           # envoyer une demande de validation
           destinataire = @facture.cibles.where(repondu_le: nil).first
           FactureMailer.with(cible: destinataire).notification_email.deliver_later
           destinataire.update!(envoyé_le: DateTime.now)
        else 
          # sinon c'est validé
          @facture.valider!
        end
      end
        
      redirect_to facture_url(@facture), notice: "Facture #{@facture.current_state} par #{params[:email]}"
    end
  end

  def action
    if factures_id = params[:factures_id]
      factures = 
        Facture
          .where(id: factures_id.keys)
          .with_validée_state
          .each do |f| 
            f.imputer! if f.validée?
        end

      flash[:notice] = "#{factures.count} facture.s modifiée.s"  
    end
    redirect_to factures_url
  end

  # DELETE /factures/1
  # DELETE /factures/1.json
  def destroy
    @facture.destroy
    respond_to do |format|
      format.html { redirect_to factures_url, notice: 'Facture détruite avec succès.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_facture
      @facture = Facture.find_by(slug: params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def facture_params
      params.require(:facture).permit(:etat, :anomalie, :num_chrono, :par, :société, :scan, :montantHT, :commentaires,
                                    cibles_attributes: [:id, :opérateur, :email, :répondu_le, :réponse, :_destroy])
    end
end
