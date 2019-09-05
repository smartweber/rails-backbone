RSpec.shared_examples "pasteable element" do |link_type, target_input_name, outer_container_locator|
  describe do
    let!(:link) do
      link_type == :image ? "http://www.google.com/images/srpr/logo11w.png" : "http://www.google.com"
    end
    let!(:user_attachment_locator) do
      link_type == :image ? '.bb-preview-image' : '.link-preview-container'
    end

    it "allows attachment by pasting direct link to it" do
      find("[name='#{target_input_name}']").click
      fill_in target_input_name, with: link
      expect do
        page.driver.execute_script("$('[name=\"#{target_input_name}\"]').trigger('paste');")
        within outer_container_locator do
          expect(page).to have_selector(user_attachment_locator)
        end
      end.to change(Attachment, :count).by(1)
    end
  end
end

RSpec.shared_examples "attachable element" do |local_selector, target_input_name, clickable_input_name|
  describe do
    it "shows preview after file attached" do
      within local_selector do
        find("[name='#{clickable_input_name}']").click if clickable_input_name
        # We need to click it in order to have input field added to DOM
        first('.bb-attach-link').click
        attach_file(target_input_name, Rails.root.join('spec/fixtures/image2.png'), visible: false)
      end
      expect(page).to have_selector('.bb-preview-image', visible: false)
    end
  end
end

RSpec.shared_examples "common notification" do |factory_name, dropdown_menu_locator|
  describe do
    before do
      Sidekiq::Testing.inline!{ @notification = FactoryGirl.create(factory_name) }
    end

    it "displayed at header upon receiving" do
      within dropdown_menu_locator do
        find(".dropdown-toggle", visible: :all).click
        expect(page).to have_selector('.bb-items li')
      end
    end

    it "can be marked as read" do
      within dropdown_menu_locator do
        find(".dropdown-toggle", visible: :all).click
        expect{ find('.bb-seenable').click }.to change(Notification.unseen, :count).by(-1)
        expect(page).not_to have_selector('.bb-items li')
        page.reload
        expect(page).not_to have_selector('.bb-items li')
      end
    end

    it "replaces previously received same-event notification" do
      FactoryGirl.create(factory_name, notifiable: @notification.notifiable)
      within dropdown_menu_locator do
        find(".dropdown-toggle", visible: :all).click
        expect(find('.bb-items li').size).to be_less_than 2
        page.reload
        expect(find('.bb-items li').size).to be_less_than 2
      end
    end
  end
end
