# @note hosts the attachment for posts/comments, both uploaded and scrapped from direct links
class AdminUserAttachment < Attachment
  has_shortened_urls
  belongs_to :user

  validates_presence_of :image
  validates_presence_of :admin_user_id

  attr_reader :link

  def file=(file)
    self.image = file
  end
end
