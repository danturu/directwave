module DirectWave
  module Uploader
    
    class Base
      include DirectWave::Uploader::Configuration
      include DirectWave::Uploader::Accreditation
      include DirectWave::Uploader::Paths
      include DirectWave::Uploader::Versions
      include DirectWave::Uploader::Connection
      
      attr_reader :model, :mounted_as
      
      def initialize(model=nil, mounted_as=nil)
        @model      = model
        @mounted_as = mounted_as
      end
      
      def save
        if has_store_key?
          # at first remove previous files
          versions.each { |name, version| version.delete } unless model[mounted_as].blank?
 
          # at second process new files
          model[mounted_as] = filename
          versions.each { |name, version| version.process }
          global_process
        end
      end
      
      def destroy
        versions.each { |name, version| version.delete }
      end
      
      def global_process; end
      
      version :original do
        def filename
          @filename ||= [extract(:guid), extract(:basename) << extract(:extname)].join("/")
        end
        
        def process
          super
          
          source_file      = @uploader.class.s3_directory.objects[@uploader.store_key]
          destination_file = AWS::S3::S3Object.new(@uploader.class.s3_directory, key)
          
          source_file.copy_to(destination_file, { acl: @uploader.s3_acl })
          source_file.delete
        end
      end      
    end # Base
    
  end # Uploader
end # DirectWave