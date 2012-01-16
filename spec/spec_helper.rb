require "directwave"
require "aws-sdk"

# Fog.mock!

S3_CREDENTIALS = {
  access_key_id: "AKIAI6L5SAFZPZRND7YQ", 
  secret_access_key: "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",
  bucket: "rspec",
  access_policy: :public_read
}

DirectWave.configure do |config|
  config.reset_config
  config.s3_access_key_id     = S3_CREDENTIALS[:access_key_id]
  config.s3_secret_access_key = S3_CREDENTIALS[:secret_access_key]
  config.s3_bucket            = S3_CREDENTIALS[:bucket]
  config.s3_access_policy     = :public_read
end