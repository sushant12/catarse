class SctController < ApplicationController
  def index
    merchant_username = 'grasruts_uat'
    merchant_password = CatarseSettings[:api_password]
    signature_passcode = CatarseSettings[:signature]
    password = Digest::SHA256.hexdigest(merchant_username+merchant_password)
    sign = Digest::SHA256.hexdigest(signature_passcode+merchant_username+'12')
    client = Savon.client(wsdl: 'https://gateway.sandbox.npay.com.np/websrv/Service.asmx?wsdl')
    params = {
        "MerchantId" => 169,
        "MerchantTxnId" => 12,
        "MerchantUserName" => merchant_username,
        "MerchantPassword" => password,
        "Signature" => sign,
        "AMOUNT" => 200,
        "purchaseDescription" => 'just testing',
    }
    response = client.call(:validate_merchant, message: params)
    @process_id = response.body[:validate_merchant_response][:validate_merchant_result][:processid]
  end
end
