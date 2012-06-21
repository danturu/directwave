module DirectWave
  
  module Uploader 
    module Accreditation
      extend ActiveSupport::Concern
      
      ##
      # === Returns
      #
      # [String] Amazon S3 acl
      #
      def s3_acl
        @s3_acl ||= s3_access_policy.to_s.gsub("_", "-")
      end

      ##
      # === Returns
      #
      # [Boolean] Amazon S3 policy
      #
      def s3_policy
        @s3_policy ||= Base64.encode64(
          {
            "expiration" => (Time.now + expiration_period).utc.iso8601,
            "conditions" => [
              {"bucket" => s3_bucket},
              ["starts-with", "$key", upload_dir],
              {"acl" => s3_acl},
              {"success_action_status" => "201"},
              ["content-length-range", 0, max_file_size],
              ["starts-with", "$Filename", ""],
              ['starts-with', '#{content_type}', '']
            ]
          }.to_json
        ).gsub("\n","")
      end
      
      ##
      # === Returns
      #
      # [Boolean] Amazon S3 signature
      #
      def s3_signature
        @s3_signature ||= Base64.encode64(
          OpenSSL::HMAC.digest(
            OpenSSL::Digest::Digest.new("sha1"), 
            s3_secret_access_key, s3_policy
          )
        ).gsub("\n","")
      end  
      
      private
      
      def guid
        UUID.generate
      end

    end # Accreditation
  end # Uploader

end # DirectWave