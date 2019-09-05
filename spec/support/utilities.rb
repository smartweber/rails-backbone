include ApplicationHelper

def stubbed_scrapper(link = 'http://localhost', is_image = false)
  title       = 'title'
  description = 'description'
  image_url   = 'http://localhost/image.jpeg'
  scrapper    = double("scrapper", link: link, title: title, description: description, image_url: image_url, run: true, is_image: is_image)
  scrapper
end

def test_image_path
  Rails.root.join('spec', 'fixtures', 'image.png')
end

def create_friendship_between(user, other_user)
  create(:friendship, user: user, friend: other_user)
  create(:friendship, user: other_user, friend: user)
end

def convert_times(attributes)
  %w(created_at updated_at).each do |attribute_name|
    next unless attributes[attribute_name]
    attributes[attribute_name] = attributes[attribute_name].to_json.gsub("\"", '')
  end
  attributes
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-error', text: message)
  end
end
