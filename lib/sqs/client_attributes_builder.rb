module SQS
  class ClientAttributesBuilder
    def self.build(environment)
      return production_attributes if %w(staging production).include?(environment)
      return development_attributes if environment == 'development'
    end

    def self.production_attributes
      aws_instance_metadata_uri = URI('http://169.254.169.254/latest/dynamic/instance-identity/document')
      instance_metadata = Net::HTTP.get(aws_instance_metadata_uri)
      region = JSON.parse(instance_metadata)['region']

      { region: region }
    end

    def self.development_attributes
      {
        region: ENV['AWS_REGION'] || 'us-east-1',
        endpoint: ENV['SQS_ENDPOINT'] || 'http://localhost:4576',
        access_key_id: 'access_key_id',
        secret_access_key: 'secret_access_key',
        verify_checksums: false
      }
    end
  end
end
