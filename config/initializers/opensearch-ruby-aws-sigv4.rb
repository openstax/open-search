# https://github.com/opensearch-project/opensearch-ruby-aws-sigv4/blob/main/lib/opensearch-aws-sigv4.rb#L70
OpenSearch::Aws::Sigv4Client.class_exec do
  def perform_request(method, path, params = {}, body = nil, headers = nil)
    signature_body = body.is_a?(Hash) ? body.to_json : body.to_s
    signature = sigv4_signer.sign_request(
      http_method: method,
      url: signature_url(path, params),
      headers: headers,
      body: signature_body
    )
    headers = (headers || {}).merge(signature.headers)

    log_signature_info(signature)

    # Patch to use signature_body instead of body on the following line:
    super(method, path, params, signature_body, headers)
  end
end
