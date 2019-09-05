class NewsThumbnailUploader < DefaultUploader
  process resize_to_fill: [700, 700]

  # Create different versions of your uploaded files:
  version :carousel_list do
    process :resize_to_fill => [155, 110]
  end

  version :stretched_full do
    process :resize_to_fill => [521, 390]
  end
end
