class EsewaController < ApplicationController
  def success
    pid = params[:oid]
    amt = params[:amt]
    rid = params[:refId]
    begin
      uri = URI.parse("https://ir-user.esewa.com.np/epay/transrec")
      uri.query = URI.encode_www_form({amt: amt, scd: "GRASRUTS", pid: pid, rid: rid})
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      resp = https.get(uri.request_uri)
      if Nokogiri::XML(resp.body).text.strip == "Success"
        p = Payment.new
        p.contribution_id = session[:contribution_id]
        p.state = 'paid'
        p.key = rid
        p.gateway = 'esewa'
        p.payment_method = 'esewa'
        p.value = amt
        p.save!
        redirect_to project_contribution_url(session[:project_id],session[:contribution_id])
      else
        raise "Something went wrong"
      end
    rescue => e
      redirect_to "http://www.grasruts.com?error=fradulant transaction detected"
    end
  end
end