class FakeContext
  include ActionView::Helpers
  include Rails.application.routes.url_helpers
  include Singleton
  include ApplicationHelper
  include UsersHelper
end
