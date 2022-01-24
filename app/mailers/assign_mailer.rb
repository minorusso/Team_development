class AssignMailer < ApplicationMailer
  default from: 'from@example.com'

  def assign_mail(email, password)
    @email = email
    @password = password
    mail to: @email, subject: I18n.t('views.messages.complete_registration')
  end
  def assignment_of_authority_mail(email)
    @email = email
    mail to: @email, subject: I18n.t('views.messages.complete_change')
  end
  def delete_agenda_mail(team_mambers)
    @team_members = team_mambers
    mail to: @team_members.map(&:email), subject: I18n.t('views.messages.delete_agenda')
  end
end