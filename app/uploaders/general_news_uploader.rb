class GeneralNewsUploader < DefaultUploader
  process :crop

  # Create different versions of your uploaded files:
  version :carousel_list do
    process :resize_to_fill => [155, 110]
  end

  version :stretched_full do
    process :resize_to_fill => [521, 390]
  end

  def crop
    manipulate! do |image|
      image.crop("#{model.thumbnail_w}x#{model.thumbnail_h}!+#{model.thumbnail_x}+#{model.thumbnail_y}")
      image
    end
  end
end
