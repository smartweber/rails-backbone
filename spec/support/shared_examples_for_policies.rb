RSpec.shared_examples "user ownership permission" do
  describe do
    let(:class_name) { described_class.to_s.gsub('Policy', '').downcase }
    it "grants access to record owned by user" do
      expect(subject).to permit(user, double(class_name.titleize, user_id: user.id))
    end

    it "denies access to record not owned by user" do
      expect(subject).not_to permit(user, double(class_name.titleize, user_id: user.id+1))
    end
  end
end

RSpec.shared_examples "id equality permission" do
  describe do
    it "grants access for the same user" do
      expect(subject).to permit(user, user)
    end

    it "denies access for other users" do
      expect(subject).not_to permit(other_user, user)
    end
  end
end
