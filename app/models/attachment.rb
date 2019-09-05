class Attachment < ActiveRecord::Base
  MAX_FILE_SIZE_MB = 5

  belongs_to :attachable, polymorphic: true

  mount_uploader :image, AttachedImageUploader
  validates_integrity_of :image
  validates_processing_of :image
  validate :image_size

  def image_size
    if image.file and image.file.size.to_f/(1000*1000) > MAX_FILE_SIZE_MB.to_f
      errors.add(:image, "You cannot upload a file greater than #{MAX_FILE_SIZE_MB.to_f}MB")
    end
  end
end
