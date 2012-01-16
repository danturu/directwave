require "spec_helper"

describe DirectWave::Uploader::Versions::Version do
  before do
    @uploader_class = Class.new(DirectWave::Uploader::Base)
    @uploader = @uploader_class.new
    @uploader.stub(:original_filename).and_return("guid/foo.bar")
    @uploader_class.version :foo
  end

  describe '#filename' do
    it "by default should return 'guid/foo-bar.bar" do
      @uploader.foo.filename.should == "guid/foo-foo.bar"
    end
  end
  
  describe '#url' do
    it "not tested yet"
  end
  
  describe '#key' do
    before { @uploader.stub(:upload_dir).and_return("uploads") }
    
    it "should return 'foo-foo" do
      @uploader.foo.key.should == "uploads/guid/foo-foo.bar"
    end
  end
  
  describe '#file' do
    it "not tested yet"
  end

  describe '#process' do
    it "not tested yet"
  end
  
  describe '#delete' do
    it "not tested yet"
  end
end

describe DirectWave::Uploader::Versions do
  before do
    @uploader_class = Class.new(DirectWave::Uploader::Base)
    @uploader = @uploader_class.new
  end

  describe '.version' do
    it "should add it to .versions" do
      @uploader_class.version :foo
      @uploader_class.versions[:foo].should be_a(Class)
      @uploader_class.versions[:foo].ancestors.should include(DirectWave::Uploader::Versions::Version)
    end

    it "should add an accessor which returns the version and add it to #versions which returns the version" do
      @uploader_class.version :foo
      @uploader.foo.should == @uploader.versions[:foo]
    end
 
    it "should apply any overrides given in a block" do
      @uploader_class.version :foo do
        def extname
          ".bar"
        end
      end
      @uploader.foo.extname.should == ".bar"
    end

    it "should reopen the same class when called multiple times" do
      @uploader_class.version :foo do
        def self.bar
          "bar"
        end
      end
      @uploader_class.version :foo do
        def self.qux
          "qux"
        end
      end
      @uploader_class.versions[:foo].bar.should == "bar"
      @uploader_class.versions[:foo].qux.should == "qux"
    end
  end  

  describe '.versions' do
    it "not tested yet"
  end
end