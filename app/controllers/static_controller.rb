# frozen_string_literal: true

class StaticController < ApplicationController
  def thank_you
    contribution = Contribution.find session[:contribution_id]
    redirect_to [contribution.project, contribution]
  end
end
