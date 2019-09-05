require 'rails_helper'

RSpec.describe CompanyRecommender, :type => :model do
  describe '#recommendations' do
    let(:user) { FactoryGirl.create(:user) }
    subject { CompanyRecommender.new(user).recommendations }
    let!(:company1) { FactoryGirl.create(:company, market_cap: 1, sector: 'Entertainment') }
    let!(:company2) { FactoryGirl.create(:company, market_cap: 2) }
    let!(:company3) { FactoryGirl.create(:company, market_cap: 10, sector: 'Entertainment') }
    let!(:company6) { FactoryGirl.create(:company, market_cap: 3) }
    let!(:company5) { FactoryGirl.create(:company, market_cap: 10, sector: 'Entertainment') }
    before { user.follow(company1) }
    context 'when there is only one company satisfying all candidate attributes' do
     let!(:company4) { FactoryGirl.create(:company, market_cap: 3) }
      before do
        2.times do
          FactoryGirl.create(:user).tap { |u| u.follow(company3) }
        end
      end
      it 'contains the same company at first position' do
        expect(subject.first).to eq company3
      end
    end
    context 'when there are more companies with same market value and sector' do
      let!(:company4) { FactoryGirl.create(:company, market_cap: 15, sector: 'Entertainment') }
      before do
        2.times do
          FactoryGirl.create(:user).tap { |u| u.follow(company3) }
        end
      end
      it 'contains the most popular company at first position' do
        expect(subject.first).to eq company3
      end
    end
    context 'when there are more companies with same popularity and sector' do
      let!(:company4) { FactoryGirl.create(:company, market_cap: 15, sector: 'Entertainment') }
      it 'contains the company with highest market value at first position' do
        expect(subject.first).to eq company4
      end
    end

  end
end
