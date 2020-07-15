class FactureMailer < ApplicationMailer
    def notification_email
        @cible= params[:cible]
        @facture = @cible.facture
        subject = "Facture n° #{@facture.num_chrono} du fournisseur '#{@facture.société}' en anomalie" 
    
        mail(to: @cible.email, cc: 'daniel.blanco@grohe.com', subject: subject)
    end
end
