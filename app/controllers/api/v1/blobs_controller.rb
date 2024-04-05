class Api::V1::BlobsController < ApplicationController

  include ApiKeyAuthenticatable

  prepend_before_action :authenticate_with_api_key!

  @@StorageService = case ENV.fetch('STORAGE_SERVICE')
                        when "DB" then DatabaseStorageService.new()
                        when "S3" then MinioStorageService.new()
                        when "LOCAL" then LocalStorageService.new()
                      end

  def index
  end

  def show

    id = params[:id]
    begin

      blob = @@StorageService.retreive(id)
      render json: {
        id: blob.id,
        data: blob.data,
        size: blob.size,
        created_at: blob.created_at
      }, status: 200

    rescue ActiveRecord::RecordNotFound => e

      render json:
      {
        message: "object does not exist!"
      },
      status: 400

    rescue Exception => e

      render json:
      {
        message: e.message
      },
      status: 400

    end

  end

  def create

    id = params[:id]
    data = params[:data]

    begin

      blob = @@StorageService.save(id, data)
      render json: {id: blob.id}, status: 201

    rescue ActiveRecord::RecordInvalid => e

      render json:
      {
        message: "object already exist!"
      },
      status: 400

    rescue Exception => e

      render json:
      {
        message: e.message
      },

      status: 400
    end

  end

end
