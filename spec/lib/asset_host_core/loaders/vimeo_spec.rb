require 'spec_helper'

describe AssetHostCore::Loaders::Vimeo do
  describe '::build_from_url' do
    it 'matches a vimeo url' do
      AssetHostCore::Loaders::Vimeo.build_from_url('http://vimeo.com/29695463').should be_a AssetHostCore::Loaders::Vimeo
    end

    it 'returns nil for invalid url' do
      AssetHostCore::Loaders::Vimeo.build_from_url('nope.com/nope').should eq nil
    end
  end

  describe '#load' do
    before :each do
      FakeWeb.register_uri(:get, %r{vimeo\.com/api},
        content_type: "application/json", body: load_api_response('vimeo/video.json'))

      FakeWeb.register_uri(:get, %r{b\.vimeocdn\.com},
        content_type: "image/jpeg", body: load_image('dude.jpg'))

      @loader = AssetHostCore::Loaders::Vimeo.build_from_url('http://vimeo.com/29695463')
      @asset  = @loader.load
    end

    it 'creates a new asset' do
      @asset.should be_a AssetHostCore::Asset
      @asset.persisted?.should eq true
    end

    it 'sets the native to be a vimeo video' do
      @asset.native.should be_a AssetHostCore::VimeoVideo
    end

    it 'sets the owner' do
      @asset.owner.should match /KPCC/
    end

    it 'sets the title' do
      @asset.title.should match /Lebowski/
    end

    it 'sets the caption' do
      @asset.caption.should match /Way out west/
    end

    it 'sets the image' do
      @asset.image.should be_a Paperclip::Attachment
    end
  end
end
