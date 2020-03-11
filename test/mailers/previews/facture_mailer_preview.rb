# Preview all emails at http://localhost:3000/rails/mailers/facture_mailer
class FactureMailerPreview < ActionMailer::Preview
    def notification
        FactureMailer.with(cible: Facture.first.cibles.first).notification_email
    end
end
