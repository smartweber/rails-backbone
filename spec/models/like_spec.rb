require 'rails_helper'

RSpec.describe Like do

  it_behaves_like "a notification trigger", :post_liked
end
