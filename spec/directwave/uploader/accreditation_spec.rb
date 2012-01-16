require "spec_helper"

describe DirectWave::Uploader::Accreditation do
  before do
    @model = mock("model")
    @uploader_class = Class.new(DirectWave::Uploader::Base)
    @uploader = @uploader_class.new(@model, "foo")
  end
  
  describe "#acl" do
    it "should return the sanitized s3 access policy" do
      @uploader.s3_acl.should == @uploader.s3_access_policy.to_s.gsub("_", "-")
    end
  end

  describe "#policy" do
    let(:decoded_s3_policy) { JSON.parse(Base64.decode64(@uploader.s3_policy)) }

    it "should return Base64-encoded JSON" do
      decoded_s3_policy.should be_a(Hash)
    end

    it "should not contain any new lines" do
      @uploader.s3_policy.should_not include("\n")
    end
    
    it "should be tested by parts"
  end
  
  describe "#signature" do
    it "should not contain any new lines" do
      @uploader.s3_signature.should_not include("\n")
    end

    it "should return a base64 encoded 'sha1' hash of the secret key and policy document" do
      Base64.decode64(@uploader.s3_signature).should == OpenSSL::HMAC.digest(
        OpenSSL::Digest::Digest.new('sha1'),
        @uploader.s3_secret_access_key, @uploader.s3_policy
      )
    end
  end
end