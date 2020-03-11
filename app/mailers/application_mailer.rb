class ApplicationMailer < ActionMailer::Base
  default from: 'mailbot@anofacto.fr'
  layout 'mailer'
end
