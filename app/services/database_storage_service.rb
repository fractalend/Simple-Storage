class DatabaseStorageService < StorageService
    def save(id, data)

        if Blob.exists?(id: id)
            raise ActiveRecord::RecordInvalid
        end
        file = Base64Helper.base64_to_binary(data)
        size = FileHelper.file_bytes_size(file.size)
        blob = Blob.create!({:id => id, :data => "", "size" => size})
        blob_storage = blob.create_blob_storage({:data => file})
        blob.data = blob_storage.id
        blob

    end

    def retreive(id)

        blob = blob = Blob.find_by!(id: id)
        blob.data = Base64Helper.binary_to_base64(blob.blob_storage.data)
        return blob

    end

end
