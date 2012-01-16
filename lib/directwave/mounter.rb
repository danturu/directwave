module DirectWave
  
  ##
  # If a Class is extended with this module, it gains the mount_uploader
  # method, which is used for mapping attributes to uploaders and allowing
  # easy assignment.
  #
  # You can use mount_uploader with pretty much any class, however it is
  # intended to be used with some kind of persistent storage, like an ORM.
  #
  module Mounter
    
    ##
    # === Returns
    #
    # [Hash{Symbol => DirectWave}] what uploaders are mounted on which columns
    #

    def uploaders
      @uploaders ||= {}
      @uploaders = superclass.uploaders.merge(@uploaders) if superclass.respond_to?(:uploaders)
      @uploaders
    end
    
    ##
    # Mounts the given uploader on the given column. This means that assigning
    # and reading from the column will upload and retrieve files. Supposing
    # that a Track class has an uploader mounted on audio, you can assign and
    # retrieve files like this:
    #
    #     @track.store_key = "s3/key/of/file"
    #     @track.audio # => <Uploader>
    #
    #     @user.audio.url # => "url/to/original/version.aac"
    #
    # Passing a block makes it possible to customize the uploader. This can be
    # convenient for brevity, but if there is any significatnt logic in the
    # uploader, you should do the right thing and have it in its own file.
    #
    # === Added instance methods
    #
    # Supposing a class has used +mount_uploader+ to mount an uploader on a column
    # named +image+, in that case the following methods will be added to the class:
    #
    # [audio]                   Returns an instance of the uploader only if anything has been uploaded
    #
    # === Parameters
    #
    # [column (Symbol)]                   the attribute to mount this uploader on
    # [uploader (DirectWave::Uploader)]  the uploader class to mount
    # [&block (Proc)]                     customize anonymous uploaders
    #
    # === Examples
    #
    # Mounting uploaders on different columns.
    #
    #     class Track
    #       mount_directwave :audio, AudioUploader
    #       mount_directwave :lyrics, LyricsUploader
    #     end
    #
    # This will add an anonymous uploader with only the default settings:
    #
    #     class Data
    #       mount_uploader :csv
    #     end
    #
    # this will add an anonymous uploader overriding the upload_dir and store_dir:
    #
    #     class Track
    #       mount_uploader :audio do
    #         def upload_dir
    #           "audio"
    #         end
    #
    #         def store_dir
    #           "audio"
    #         end
    #       end
    #     end
    #

    def mount_directwave(column, uploader=nil)
      uploader = Class.new(uploader || DirectWave::Uploader::Base)
      uploaders[column.to_sym] = uploader
      
      class_eval <<-RUBY, __FILE__, __LINE__+1
        def #{column}
          @uploader ||= self.class.uploaders[:#{column}].new(self, :#{column})
        end
      RUBY
    end

  end # Mounter
end # DirectWave