class SigV4Helper

    def initialize(credentials)
        @service = 's3'
        @region = 'us-east-1' #default
        @secret_access_key = credentials[:secretKey]
        @access_key_id = credentials[:accessKey]
    end
    def sign_request(request)

        http_method = extract_http_method(request)
        url = extract_url(request)
        headers = downcase_headers(request[:headers]) # do we need that?

        datetime = headers['x-amz-date']
        datetime ||= Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
        date = datetime[0,8]

        content_sha256 = headers['x-amz-content-sha256']
        content_sha256 ||= sha256_hexdigest(request[:body] || '')

        sigv4_headers = {}
        sigv4_headers['host'] = headers['host'] || host(url)
        sigv4_headers['x-amz-date'] = datetime


        sigv4_headers['x-amz-content-sha256'] ||= content_sha256

        headers = headers.merge(sigv4_headers) # merge so we do not modify given headers hash

        # compute signature parts
        creq = canonical_request(http_method, url, headers, content_sha256)
        sts = string_to_sign(datetime, creq)
        sig = signature( date, sts)

        # apply signature
        sigv4_headers['authorization'] = [
          "AWS4-HMAC-SHA256 Credential=#{@access_key_id}/#{credential_scope(date)}",
          "SignedHeaders=#{signed_headers(headers)}",
          "Signature=#{sig}",
        ].join(', ')

        return sigv4_headers
    end

    def extract_http_method(request)
        if request[:http_method]
          request[:http_method].upcase
        else
          msg = "missing required option :http_method"
          raise ArgumentError, msg
        end
    end

    def extract_url(request)
        if request[:url]
          URI.parse(request[:url].to_s)
        else
          msg = "missing required option :url"
          raise ArgumentError, msg
        end
    end

    def downcase_headers(headers)
        (headers || {}).to_hash.inject({}) do |hash, (key, value)|
          hash[key.downcase] = value
          hash
        end
    end

    def sha256_hexdigest(value)
        if (File === value)
            OpenSSL::Digest::SHA256.file(value).hexdigest
        else
            OpenSSL::Digest::SHA256.hexdigest(value)
        end
    end

    def host(uri)
        if uri.default_port == uri.port
          uri.host
        else
          "#{uri.host}:#{uri.port}"
        end
    end

    def canonical_request(http_method, url, headers, content_sha256)
        [
          http_method,
          url.path,
          '',
          canonical_headers(headers) + "\n",
          signed_headers(headers),
          content_sha256,
        ].join("\n")
    end

    def string_to_sign(datetime, canonical_request)

        [
          'AWS4-HMAC-SHA256',
          datetime,
          credential_scope(datetime[0,8]),
          sha256_hexdigest(canonical_request),
        ].join("\n")

    end

    def signature(date, string_to_sign)
        k_date = hmac("AWS4" + @secret_access_key, date)
        k_region = hmac(k_date, @region)
        k_service = hmac(k_region, @service)
        k_credentials = hmac(k_service, 'aws4_request')
        hexhmac(k_credentials, string_to_sign)
    end

    def hexhmac(key, value)
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), key, value)
    end

    def canonical_headers(headers)

        headers = headers.inject([]) do |hdrs, (k,v)|
          hdrs << [k,v]
        end

        headers = headers.sort_by(&:first)
        headers.map{|k,v| "#{k}:#{v.to_s}" }.join("\n")

    end

    def signed_headers(headers)

        headers.inject([]) do |signed_headers, (header, _)|
        signed_headers << header
        end.sort.join(';')

    end

    def hmac(key, value)
      OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), key, value)
    end

    def credential_scope(date)
      [
        date,
        @region,
        @service,
        'aws4_request',
      ].join('/')
    end
end
