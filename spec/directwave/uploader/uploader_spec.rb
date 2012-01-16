describe DirectWave::Uploader do
  before do
    @model = mock('a model object')
    @uploader_class = Class.new(DirectWave::Uploader::Base)
    @uploader = @uploader_class.new(@model, :foo)
  end

  describe '#model' do
    it "should be remembered from initialization" do
      puts @uploader.store_key
      @uploader.model.should == @model
    end
  end

  describe '#mounted_as' do
    it "should be remembered from initialization" do
      @uploader.model.should == @model
      @uploader.mounted_as.should == :foo
    end
  end
  
  describe "#save" do
    it "not tested yer and not finished"
  end

  describe "#destroy" do
    it "not tested yer and not finished"
  end
  
  describe "#original version" do
    it "not tested yer and not finished"
  end  
end
