class FacturesController < ApplicationController
  before_action :authenticate_user!, except: [:validation]
  before_action :set_facture, only: [:show, :edit, :update, :destroy]

  # GET /factures
  # GET /factures.json
  def index
    @factures = Facture.all

    unless params[:search].blank?
      s = "'%#{params[:search]}%'"
      @factures = @factures.where(Arel.sql("factures.num_chrono LIKE #{s} OR factures.société LIKE #{s} OR factures.par LIKE #{s} OR factures.cible LIKE #{s}"))
    end

    unless params[:etat].blank?
      @factures = @factures.where("factures.etat = ?", params[:etat])
    end

    unless params[:anomalie].blank?
      @factures = @factures.where("factures.anomalie = ?", params[:anomalie])
    end
  end

  # GET /factures/1
  # GET /factures/1.json
  def show
  end

  # GET /factures/new
  def new
    @facture = Facture.new
    3.times { @facture.cibles.build }
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
        # Envoyer à la première et à toutes les autres cibles
        # Le premier qui valide a gagné :)
        @facture.cibles.each_with_index do |c, i|
          if i.zero? || c.opérateur == "OU" 
            FactureMailer.with(cible: c).notification_email.deliver_now
            c.update!(envoyé_le: DateTime.now)
          end 
        end
        @facture.update!(etat: "envoyée")

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

    if etat = params[:commit]
      # Marquer ce que la cible a répondu
      @facture.cibles.where(email: params[:email]).each do |c|
        c.update!(repondu_le: DateTime.now, réponse: etat, commentaires: params[:commentaires])
      end

      # Marquer la facture traitée s'il fallait au moins une validation (opérateur 'OU')
      @facture.update!(etat: etat.downcase) if @facture.cibles.pluck(:opérateur).uniq.include?('OU')  

      redirect_to facture_validation_url(@facture), notice: "Facture #{etat} !"
    end
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
      params.require(:facture).permit(:etat, :anomalie, :num_chrono, :par, :société, :scan, :montantHT,
                                    cibles_attributes: [:id, :opérateur, :email, :répondu_le, :réponse, :_destroy])
    end
end
