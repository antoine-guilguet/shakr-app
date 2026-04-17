class VoiceController < ApplicationController
  before_action :authenticate_user!

  def show
    @voice_autostart = params[:autostart].present?
  end
end
