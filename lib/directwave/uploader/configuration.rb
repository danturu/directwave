module DirectWave
  
  module Uploader
    module Configuration
      extend ActiveSupport::Concern
      
      included do
        add_config :s3_access_policy
        add_config :s3_bucket
        add_config :s3_access_key_id
        add_config :s3_secret_access_key
        add_config :s3_region
        add_config :s3_authentication_timeout
        
        add_config :max_file_size
        add_config :expiration_period
        
        add_config :store_dir
        add_config :upload_dir
        add_config :cache_dir

        reset_config
      end
      
      module ClassMethods
        def add_config(name)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            class << self
              def #{name}(value=nil)
                @#{name} = value if value
                return @#{name} if self.object_id == #{self.object_id} || defined?(@#{name})
                name = superclass.#{name}
                return nil if name.nil? && !instance_variable_defined?("@#{name}")
                @#{name} = name && !name.is_a?(Module) && !name.is_a?(Symbol) && !name.is_a?(Numeric) && !name.is_a?(TrueClass) && !name.is_a?(FalseClass) ? name.dup : name
              end
              
              def #{name}=(value)
                @#{name} = value
              end
            end 
            
            def #{name}
              self.class.#{name}
            end
          RUBY
        end
        
        def configure
          yield self
        end

        def reset_config
          configure do |config|
            config.s3_access_policy = :public_read
            config.s3_region        = "us-east-1"
            config.s3_authentication_timeout = 60.minutes
            
            config.max_file_size   = 300.megabytes
            config.expiration_period = 6.hours

            config.store_dir  = "uploads"
            config.upload_dir = "uploads/tmp"
            config.cache_dir  = 'uploads/cache'
          end
        end
      end # ClassMethods
    end #Configuration
  end # Uploader
  
end # DirectWave