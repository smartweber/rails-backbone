RSpec.shared_examples "a notification trigger" do |notification_worker_method|
  describe "#delayed_notification" do
    it do
      expect( NotificationWorker ).to receive(notification_worker_method)
      create(described_class.to_s.downcase.to_sym)
    end
  end

  describe "callbacks" do

    describe "#delayed_notification" do

      it do
        expect_any_instance_of( described_class ).to receive(:delayed_notification)
        create(described_class.to_s.downcase.to_sym)
      end
    end
  end
end
