module DirectWave
  
  module Uploader
    module Paths
      extend ActiveSupport::Concern
      
      def url(version=:original)
        versions[version.to_sym].url || default_url
      end
      
      def key(version=:original)
        versions[version.to_sym].key
      end
      
      def default_url; end
      
      def filename(part=nil)
        return original_filename unless has_store_key?
        
        key_path = store_key.split("/")
        filename_parts = []
        filename = filename_parts.unshift(key_path.pop)
        unique_key = key_path.pop
        filename_parts.unshift(unique_key) if unique_key
        filename_parts.join("/")
      end
              
      def original_filename
        model[mounted_as.to_s] if model.respond_to?(mounted_as)
      end
            
      def store_key=(string)
        @store_key = string
      end
        
      def store_key
        @store_key ||= "#{upload_dir}/#{guid}/${filename}"
      end
      
      def has_store_key?
        @store_key.present? && !(@store_key =~ /#{Regexp.escape("${filename}")}\z/)
      end       
    end # Paths
  end # Uploader
  
end