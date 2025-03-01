# frozen_string_literal: true

class SubmitterMailer < ApplicationMailer
  def invitation_email(submitter, body: nil, subject: nil)
    @current_account = submitter.submission.template.account
    @submitter = submitter
    @body = body.presence

    @email_config = @current_account.account_configs.find_by(key: AccountConfig::SUBMITTER_INVITATION_EMAIL_KEY)

    subject =
      if @email_config || subject.present?
        ReplaceEmailVariables.call(subject.presence || @email_config.value['subject'], submitter:)
      else
        'You have been invited to submit a form'
      end

    mail(to: @submitter.friendly_name,
         from: from_address_for_submitter(submitter),
         subject:,
         reply_to: (submitter.submission.created_by_user || submitter.template.author)&.friendly_name)
  end

  def completed_email(submitter, user, bcc: nil)
    @current_account = submitter.submission.template.account
    @submitter = submitter
    @submission = submitter.submission
    @user = user

    Submissions::EnsureResultGenerated.call(submitter)

    @email_config = @current_account.account_configs.find_by(key: AccountConfig::SUBMITTER_COMPLETED_EMAIL_KEY)

    add_completed_email_attachments!(submitter)

    subject =
      if @email_config
        ReplaceEmailVariables.call(@email_config.value['subject'], submitter:)
      else
        submitters = submitter.submission.submitters.order(:completed_at)
                              .map { |e| e.name || e.email || e.phone }.join(', ')
        %(#{submitter.submission.template.name} has been completed by #{submitters})
      end

    mail(from: from_address_for_submitter(submitter),
         to: user.friendly_name,
         bcc:,
         subject:)
  end

  def documents_copy_email(submitter, to: nil)
    @current_account = submitter.submission.template.account
    @submitter = submitter

    Submissions::EnsureResultGenerated.call(@submitter)

    @documents = add_completed_email_attachments!(submitter)

    @email_config = @current_account.account_configs.find_by(key: AccountConfig::SUBMITTER_DOCUMENTS_COPY_EMAIL_KEY)

    subject =
      if @email_config
        ReplaceEmailVariables.call(@email_config.value['subject'], submitter:)
      else
        'Your copy of documents'
      end

    mail(from: from_address_for_submitter(submitter),
         to: to || @submitter.friendly_name,
         subject:)
  end

  private

  def add_completed_email_attachments!(submitter)
    documents = Submitters.select_attachments_for_download(submitter)

    documents.each do |attachment|
      attachments[attachment.filename.to_s] = attachment.download
    end

    if submitter.submission.audit_trail.present?
      attachments[submitter.submission.audit_trail.filename.to_s] = submitter.submission.audit_trail.download
    end

    documents
  end

  def from_address_for_submitter(submitter)
    submitter.submission.created_by_user&.friendly_name || submitter.submission.template.author.friendly_name
  end
end
