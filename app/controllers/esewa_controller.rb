class EsewaController < ApplicationController
  def success
    pid = params[:pid]
    amt = params[:amt]
    ref_id = params[:ref_id]
    p = Payment.new
    p.contribution_id = session[:contribution_id]
    p.state = 'paid'
    p.key = ref_id
    p.gateway = 'esewa'
    p.payment_method = 'esewa'
    p.value = amt
    p.save!
    redirect_to project_contribution_url(session[:project_id],session[:contribution_id])
  end
end