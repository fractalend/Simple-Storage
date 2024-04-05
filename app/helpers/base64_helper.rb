class Base64Helper
    def self.binary_to_base64(binary)
        str = binary.to_s
        encoded_file = Base64.encode64(str).gsub(/\n/, "")
        encoded_file
    end
    def self.base64_to_binary(base64_data)
        return base64_data unless base64_data.present? && base64_data.is_a?(String)
        decoded_file = Base64.decode64(base64_data)
        decoded_file
    end
  end
