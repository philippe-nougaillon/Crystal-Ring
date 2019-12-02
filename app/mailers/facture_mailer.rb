class FactureMailer < ApplicationMailer
    def notification_email
        @facture= params[:facture]
        mail(to: @facture.cible, subject: 'Facture en anomalie !')
    end
end
