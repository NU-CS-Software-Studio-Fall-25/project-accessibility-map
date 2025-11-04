if Rails.env.development?
  require "openssl"

  # Build a cert store from system defaults but with CRL checks disabled
  store = OpenSSL::X509::Store.new
  store.set_default_paths
  begin
    # Some Ruby/OpenSSL builds expose .flags; if not, this rescue keeps going.
    store.flags = store.flags & ~(
      OpenSSL::X509::V_FLAG_CRL_CHECK | OpenSSL::X509::V_FLAG_CRL_CHECK_ALL
    )
  rescue NoMethodError
    # If flags writer isn't available, we still proceed with the store as-is.
  end

  # Apply the store globally for new SSL contexts
  OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:cert_store] = store
  OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:verify_mode] = OpenSSL::SSL::VERIFY_PEER
end