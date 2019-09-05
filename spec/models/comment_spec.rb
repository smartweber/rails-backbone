require 'rails_helper'

RSpec.describe Comment do

  it_behaves_like "a notification trigger", :new_comment
end
