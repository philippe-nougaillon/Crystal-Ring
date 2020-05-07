class NotifierDestinataireJob < ApplicationJob
  include SuckerPunch::Job

  def perform(destinataire)
    # Envoyer le mail au destinataire
    FactureMailer.with(cible: destinataire).notification_email.deliver_now

    # Mise à jour de la date d'envoi
    destinataire.update!(envoyé_le: DateTime.now)
  end
end
