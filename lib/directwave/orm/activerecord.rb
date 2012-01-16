require 'active_record'

module DirectWave
  module ActiveRecord
    
    include DirectWave::Mounter
    
    ##
    # See +DirectWave::Mounter#mount_uploader+ for documentation
    #
    # === Added instance methods
    #
    # Supposing a class has used +mount_uploader+ to mount an uploader on a column
    # named +image+, in that case the following methods will be added to the class:
    #
    # [#{column}_from_key]      Returns the key of assigned file 
    # [#{column}_from_key=]     Assign file from S3 key 
    #
    
    def mount_directwave(column, uploader=nil)
      super

      instance_eval <<-RUBY, __FILE__, __LINE__+1
      RUBY
      
      class_eval <<-RUBY, __FILE__, __LINE__+1
        attr_accessible :#{column}_from_key
        
        def #{column}_from_key
          send(:#{column}).store_key
        end

        def #{column}_from_key=(string)
          send(:#{column}).store_key = string
        end
      
        before_save do
          send(:#{column}).save
        end
        
        after_destroy do
          send(:#{column}).destroy
        end
      RUBY
    end
  end # ActiveRecord
end # DirectWave

ActiveRecord::Base.extend DirectWave::ActiveRecord
