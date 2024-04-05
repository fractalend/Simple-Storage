class MinioStorageService < StorageService

    @@minio_url = "#{ENV.fetch('MINIO_HOST')}/#{ENV.fetch('MINIO_BUCKET_NAME')}"
    @@creds = {
        accessKey: "#{ENV.fetch('MINIO_ACCESS_KEY')}",
        secretKey: "#{ENV.fetch('MINIO_SECRET_ACCESS_KEY')}"
  }

    def save (id, data)

        if Blob.exists?(id: id)
            raise ActiveRecord::RecordInvalid
        end

        file = Base64Helper.base64_to_binary(data)

        request = {
                http_method: 'put',
                url: "#{@@minio_url}/#{id}",
                headers: {},
                body: file
        }

        signer = SigV4Helper.new(@@creds)
        headers = SigV4Helper.sign_request(request)
        response = HTTParty.put(request[:url], body: request[:body], headers: headers)

        case response.code
        when (200...300) #2xx
            size = FileHelper.file_bytes_size(file.size)
            blob = Blob.create!({:id => id, :data => request[:url], "size" => size})
            return blob
        else
            raise "Invalid Request to Minio #{response.code}"
        end

    end

    def retreive (id)

            blob = Blob.find_by!(id: id)

            request = {
                http_method: 'get',
                url: "#{blob.data}",
                headers: {},
                body: ''
            }

            signer = SigV4Helper.new(@@creds)
            headers = SigV4Helper.sign_request(request)
            response = HTTParty.get(request[:url], body: request[:body], headers: headers)

            case response.code
            when (200...300) #2xx
                data = Base64Helper.binary_to_base64(response)
                blob.data = data
                return blob
            else
                raise "Invalid Request to Minio #{response.code}"
            end

    end

end
