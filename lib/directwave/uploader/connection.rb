module DirectWave
  
  module Uploader
    module Connection
      extend ActiveSupport::Concern
      included do
        class_attribute :_s3_connection, :_s3_directory, :instance_reader => false, :instance_writer => false
      end
      
      module ClassMethods
        # If no argument is given, it will simply return the currently used storage engine.
        #
        # === Parameters
        #
        # [storage (Symbol, Class)] The storage engine to use for this uploader
        #
        # === Returns
        #
        # [Class] the storage engine to be used with this uploader
        def s3_connection
          self._s3_connection ||= AWS::S3.new(
            access_key_id: self.s3_access_key_id,
            secret_access_key: self.s3_secret_access_key,
            s3_endpoint: "s3-#{self.s3_region}.amazonaws.com"
          )
        end
        
        def s3_directory
          self._s3_directory ||= s3_connection.buckets[self.s3_bucket]
        end
      end # ClassMethods   
      
    end
  end
  
end