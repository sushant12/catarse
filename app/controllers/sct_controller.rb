class SctController < ApplicationController
  # not using this for now
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
    merchant_username = 'grasruts' # test'grasruts_uat'
    merchant_password = CatarseSettings[:api_password]
    signature_passcode = CatarseSettings[:signature]
    # transaction_id = Time.now.to_i.to_s
    password = Digest::SHA256.hexdigest(merchant_username+merchant_password)
    sign = Digest::SHA256.hexdigest(signature_passcode+merchant_username+transaction_id)
    # client = Savon.client(wsdl: 'https://gateway.sandbox.npay.com.np/websrv/Service.asmx?wsdl')
    client = Savon.client(wsdl: 'https://gateway.npay.com.np/websrv/Service.asmx?wsdl')

    @params = {
        "MerchantId" => 83, #169,
        "MerchantTxnId" => transaction_id,
        "MerchantUserName" => merchant_username,
        "MerchantPassword" => password,
        "Signature" => sign,
        "GTWREFNO" => ref_no
    }
    response = client.call(:check_transaction_status, message: @params)
    if response.body[:check_transaction_status_response][:check_transaction_status_result][:status_code] == '0'
      p = Payment.new
      p.contribution_id = session[:contribution_id]
      p.state = 'paid'
      p.key = response.body[:check_transaction_status_response][:check_transaction_status_result][:merchant_transactionid]
      p.gateway = 'npay'
      p.payment_method = 'npay'
      p.value = response.body[:check_transaction_status_response][:check_transaction_status_result][:amount]
      p.gtwrefno = response.body[:check_transaction_status_response][:check_transaction_status_result][:gtwrefno]
      p.description = response.body[:check_transaction_status_response][:check_transaction_status_result][:merchant_decs]
      p.concerned_bank = response.body[:check_transaction_status_response][:check_transaction_status_result][:concerned_bank]
      p.gateway_data = response.body[:check_transaction_status_response][:check_transaction_status_result].to_json
      p.save!
    end
    redirect_to project_contribution_url(session[:project_id],session[:contribution_id])
  end

  def delivery
    render plain: '0'
  end

  def ipay
    binding.pry
    @order_number = params[:ordernumber]
    @customer_email = params[:customer_email]
    @amount = params[:amount]
    @confirmation_code = params[:confirmation_code]
    @transaction_id = params[:transactionid]
    @session_key = params[:session_key]

  end

  def pickup
    order_no = params["OrderNo"]
    description = params["Description"]
    email = params["customer_email"]
    amount = params["Amount"]
    posting = params["posting"]
    binding.pry
  end
end