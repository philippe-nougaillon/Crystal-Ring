class FactureMailer < ApplicationMailer
    def notification_email
        @cible= params[:cible]
        @facture = @cible.facture
        mail(to: @cible.email, subject: 'Facture en anomalie !')
    end
end
