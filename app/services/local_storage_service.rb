class LocalStorageService < StorageService

    @@LocalStoragePath = ENV.fetch('LOCAL_STORAGE_PATH')

    def save(id, data)

        if Blob.exists?(id: id)
            raise ActiveRecord::RecordInvalid
        end
        path = "#{@@LocalStoragePath}/#{id}"
        file_data = Base64Helper.base64_to_binary(data)
        size = FileHelper.file_bytes_size(file_data.size)
        File.open(path, 'wb') { |file| file.write(file_data) }
        blob = Blob.create!({:id => id, :data => path, "size" => size})
        blob


    end

    def retreive(id)

        blob = Blob.find_by!(id: id)
        bdata = File.open(blob.data, 'rb') { |f| f.read }
        blob.data = Base64Helper.binary_to_base64(bdata)
        blob

    end

end
