# encoding: utf-8

class <%= class_name %>Uploader < DirectWave::Uploader::Base
  # Override the directory where uploaded files will be stored.
  def store_dir
    "uploads/#{model.class.to_s.underscore.pluralize}/#{mounted_as}"
  end
  
  # Override the directory where files will be uploaded.
  def upload_dir
    "uploads/tmp/#{Time.new.to_date.to_s}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/default.ext")
  #
  #   "fallback/default.ext"
  # end
  # Create different versions of your uploaded files:
  # version :audio do
  #   def filename
  #     @filename ||= [extract(:guid), [extract(:basename), @name].join("-") << extract(:extname)].join("/")
  #   end
  #   
  #   def process
  #     super
  #
  #     # processing code goes here
  #   end
  # end
end