CarrierWave.configure do |config|
  if Rails.env.production? || Rails.env.staging?
    config.fog_credentials = {
      provider:          'AWS',
      use_iam_profile:   true,
      region:            APP_CONFIG[:aws_region]
    }
    config.fog_directory    = APP_CONFIG[:fog][:directory]
    config.asset_host       = APP_CONFIG[:fog][:asset_host]
    config.fog_public       = true
  elsif Rails.env.development?
    config.fog_credentials = {
      provider:              'AWS',
      aws_access_key_id:     'AKIAJJSM63QN4KZRH7MA',
      aws_secret_access_key: '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',
      region:                APP_CONFIG[:aws_region]
    }
    config.fog_directory    = APP_CONFIG[:fog][:directory]
    config.asset_host       = APP_CONFIG[:fog][:asset_host]
    config.fog_public       = true
  elsif Rails.env.test? || Rails.env.cucumber?
    config.storage = :file
    config.enable_processing = false
  end
end
