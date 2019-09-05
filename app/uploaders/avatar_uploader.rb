class AvatarUploader < DefaultUploader
  process :resize_to_fit => [200, 200]

  # Create different versions of your uploaded files:
  version :medium do
    process :resize_to_fit => [92, 92]
  end
end
