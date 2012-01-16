# encoding: utf-8

require "active_support/core_ext"
require "active_support/concern"
require "uuid"
require "aws-sdk"
require "base64" 

module DirectWave
  class << self
    def configure(&block)
      DirectWave::Uploader::Base.configure(&block)
    end
  end
    
  autoload :Mounter, "directwave/mounter"
  autoload :VERSION, "directwave/version"

  module Uploader
    autoload :Base, "directwave/uploader/uploader"
    autoload :Configuration, "directwave/uploader/configuration"
    autoload :Accreditation, "directwave/uploader/accreditation"
    autoload :Paths, "directwave/uploader/paths"
    autoload :Versions, "directwave/uploader/versions"
    autoload :Connection, "directwave/uploader/connection"
  end
end

require "directwave/railtie" if defined?(Rails) 
