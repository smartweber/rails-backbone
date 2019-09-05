class ArticleThumbnailUploader < DefaultUploader
  process :crop

  def crop
    manipulate! do |image|
      image.crop("#{model.thumbnail_w}x#{model.thumbnail_h}!+#{model.thumbnail_x}+#{model.thumbnail_y}")
      image
    end
  end
end
