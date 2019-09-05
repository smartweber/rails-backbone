class PictureUploader < DefaultUploader
  process resize_to_limit: [400, 400]
end
