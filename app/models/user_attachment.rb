# @note hosts the attachment for posts/comments, both uploaded and scrapped from direct links
class UserAttachment < Attachment
  TYPES = %w(image link)

  has_shortened_urls
  belongs_to :user
  before_create :set_user_id
  after_create :generate_short_url

  validates_presence_of :type_of_attachment
  validates_inclusion_of :type_of_attachment, in: TYPES
  validates :link, presence: true, allow_blank: false, on: :create, if: 'self.type_of_attachment.nil?'

  attr_reader :link

  # TODO
  def link=(new_link)
    begin
      scrapper = PreviewScrapper.new(new_link)
      scrapper.run
      if scrapper.is_image
        self.remote_image_url   = scrapper.image_url
        self.type_of_attachment = 'image'
      else
        self.title              = scrapper.title
        self.description        = scrapper.description
        self.remote_image_url   = scrapper.image_url
        self.type_of_attachment = 'link'
      end
      @link = new_link
    rescue
      self.errors.add(:link, 'Provided link is incorrect')
    end if new_link
  end

  def is_link?
    self.type_of_attachment == 'link'
  end

  def set_user_id
    self.user_id ||= self.attachable.try(:user_id)
  end

  def generate_short_url
    Shortener::ShortenedUrl.generate(link, owner: self)
  end
end
