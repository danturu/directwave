module DirectWave
  
  module Uploader    
    module Versions
      class Version
        def initialize(uploader, name)
          @uploader = uploader
          @name     = name
        end
        
        def filename
          @filename ||= [extract(:guid), [extract(:basename), @name].join("-") << extract(:extname)].join("/")
        end

        def url
          @url ||= begin
            if @uploader.s3_access_policy != :public_read
              file.url_for(:get, { expires: @uploader.s3_authentication_timeout }).to_s
            else
              file.public_url.to_s
            end
          end
        end
        
        def key
          @key ||= File.join([@uploader.store_dir, filename].compact)
        end
        
        def file
          @file ||= @uploader.class.s3_directory.objects[key]
        end
        
        def process
          @file     = nil
          @filename = nil
          @url      = nil
          @key      = nil
        end
        
        def delete
          file.delete if file.exists? 
        end
        
        private
        
        def extract(part)
          part     = part.to_sym
          key_path = @uploader.original_filename.split("/")
          filename = key_path.pop
          guid     = key_path.pop
          
          case part
          when :guid
            guid
          when :basename
            File.basename(filename, ".*")
          when :extname
            File.extname(filename)
          else
            filename
          end           
        end
        
      end # Version
      
      extend ActiveSupport::Concern
      
      included do
        if respond_to?(:class_inheritable_accessor)
          ActiveSupport::Deprecation.silence do
            class_inheritable_accessor :versions, :instance_reader => false, :instance_writer => false
          end
        else
          class_attribute :versions, :instance_reader => false, :instance_writer => false
        end
        
        self.versions = {}
      end
           
      module ClassMethods
        
        ##
        # Adds a new version to this uploader
        #
        # === Parameters
        #
        # [name (#to_sym)] name of the version
        # [&block (Proc)] a block to eval on this version of the uploader
        #
        # === Examples
        #
        #     class Video < DirectWave::Uploader::Base
        #
        #       version :iphone do
        #         def filename
        #           @filename ||= [extract(:guid), "iphone-video" << extract(:extname)].join("/")
        #         end
        #         
        #         def process
        #           super
        #
        #           # processing version here with zencoder.com or another encoding cloud service
        #         end
        #       end
        #
        #     end
        #
        def version(name, &block)
          name = name.to_sym
          unless versions[name]
            version = Class.new(Version)

            # Add the current version hash to class attribute :versions
            current_version = {}
            current_version[name] = version
            self.versions = versions.merge(current_version)

            class_eval <<-RUBY
              def #{name}
                versions[:#{name}]
              end
            RUBY
          end
          versions[name].class_eval(&block) if block
          versions[name]
        end
        
      end # ClassMethods

      ##
      # Returns a hash mapping the name of each version of the Version to an instance of it
      #
      # === Returns
      #
      # [Hash{Symbol => DirectWave::Versions::Version}] a list of version instances
      #
      def versions
        return @versions if @versions
        @versions = {}
        self.class.versions.each do |name, version|
          @versions[name] = version.new(self, name)
        end
        @versions
      end
      
    end # Versions    
  end # Uploader
  
end# DirectWave