require 'net/http'

class PreviewScrapper
  attr_accessor :link, :is_image, :image_url, :title, :description

  ALLOWED_EXTENSIONS = /.(jpg|jpeg|png|gif)$/

  def initialize(link)
    @link = link
    raise "No link provided" if link.blank?
    @is_image = image_url_provided?
  end

  def run
    if is_image
      @image_url = link
    else
      doc             = Nokogiri::HTML(open(link, 'User-Agent' => 'firefox', :allow_redirections => :safe))
      css_description = doc.css("meta[name='description']")
      css_image       = doc.css("meta[property='og:image']")
      @title          = doc.css('title').text
      @description    = css_description.try(:first).try(:[], 'content')
      @image_url      = css_image.try(:first).try(:[], 'content')
    end
  end

  # Returns extension found in URL
  def image_url_provided?
    matchdata = @link.match(PreviewScrapper::ALLOWED_EXTENSIONS)
    matchdata ? true : false
  end
end
