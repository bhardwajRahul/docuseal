# frozen_string_literal: true

class WebhookSettingsController < ApplicationController
  before_action :load_encrypted_config
  authorize_resource :encrypted_config, parent: false

  def show; end

  def create
    @encrypted_config.update!(encrypted_config_params)

    redirect_back(fallback_location: settings_webhooks_path, notice: 'Webhook URL has been saved.')
  end

  def update
    submitter = current_account.submitters.where.not(completed_at: nil).order(:id).last

    SendFormCompletedWebhookRequestJob.perform_later(submitter)

    redirect_back(fallback_location: settings_webhooks_path, notice: 'Webhook request has been sent.')
  end

  private

  def load_encrypted_config
    @encrypted_config =
      current_account.encrypted_configs.find_or_initialize_by(key: EncryptedConfig::WEBHOOK_URL_KEY)
  end

  def encrypted_config_params
    params.require(:encrypted_config).permit(:value)
  end
end
