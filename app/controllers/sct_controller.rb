class SctController < ApplicationController
  def index
    redirect '/' unless current_user
    merchant_username = 'grasruts_uat'
    merchant_password = CatarseSettings[:api_password]
    signature_passcode = CatarseSettings[:signature]
    transaction_id = Time.now.to_i.to_s
    password = Digest::SHA256.hexdigest(merchant_username+merchant_password)
    sign = Digest::SHA256.hexdigest(signature_passcode+merchant_username+transaction_id)
    client = Savon.client(wsdl: 'https://gateway.sandbox.npay.com.np/websrv/Service.asmx?wsdl')
    @params = {
        "MerchantId" => 169,
        "MerchantTxnId" => transaction_id,
        "MerchantUserName" => merchant_username,
        "MerchantPassword" => password,
        "Signature" => sign,
        "AMOUNT" => session[:value],
        "purchaseDescription" => "Contributed to #{session[:project_name]} by #{current_user.name} -- #{current_user.email}"
    }
    response = client.call(:validate_merchant, message: @params)
    @process_id = response.body[:validate_merchant_response][:validate_merchant_result][:processid]
  end

  def thanks
    # Grab POST variables
    transaction_id = params["MERCHANTTXNID"]
    ref_no = params["GTWREFNO"]	# Reference no provided by gateway
    merchant_username = 'grasruts_uat'
    merchant_password = CatarseSettings[:api_password]
    signature_passcode = CatarseSettings[:signature]
    # transaction_id = Time.now.to_i.to_s
    password = Digest::SHA256.hexdigest(merchant_username+merchant_password)
    sign = Digest::SHA256.hexdigest(signature_passcode+merchant_username+transaction_id)
    client = Savon.client(wsdl: 'https://gateway.sandbox.npay.com.np/websrv/Service.asmx?wsdl')
    @params = {
        "MerchantId" => 169,
        "MerchantTxnId" => transaction_id,
        "MerchantUserName" => merchant_username,
        "MerchantPassword" => password,
        "Signature" => sign,
        "GTWREFNO" => ref_no
    }
    @response = client.call(:CheckTransactionStatus, message: @params)
    # @process_id = response.body[:validate_merchant_response][:validate_merchant_result][:processid]
    # redirect_to project_contribution_url(session[:project_id],session[:contribution_id])
  end
end