class NotifierDestinataireJob < ApplicationJob
  queue_as :default

  def perform(destinataire)
    # Envoyer le mail au destinataire
    FactureMailer.with(cible: destinataire).notification_email

    # Mise à jour de la date d'envoi
    destinataire.update!(envoyé_le: DateTime.now)
  end
end
