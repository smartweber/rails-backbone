require 'rails_helper'

describe FilelessIO, type: :model do
  let(:raw_data) do
    File.read(Rails.root.join('spec/fixtures/image2.png'), encoding: 'binary')
  end
  let(:headerless_file_data) { Base64.strict_encode64(raw_data) }
  let(:base64_encoded_file) do
    headerless_file_data.dup.insert(0, 'srcdata:image/png;base64,')
  end

  describe "#initialize" do

    it "passes decoded string" do
      expect(FilelessIO.new(base64_encoded_file).string).to be_eql(raw_data)
    end
  end

  describe "#splitBase64" do

    it "sets attributes correctly" do
      io = FilelessIO.new(base64_encoded_file)
      io.send(:splitBase64, raw_data)
      expect(io.type).to be_eql('image/png')
      expect(io.extension).to be_eql('png')
      expect(io.encoder).to be_eql('base64')
      expect(io.raw_data).to be_eql(headerless_file_data)
    end
  end
end
