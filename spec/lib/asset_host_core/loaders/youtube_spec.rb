require 'spec_helper'

describe AssetHostCore::Loaders::YouTube do
  describe '::build_from_url' do
    it 'matches a youtube URL' do
      loader = AssetHostCore::Loaders::YouTube.build_from_url('http://www.youtube.com/watch?v=y8Kyi0WNg40')
      loader.should be_a AssetHostCore::Loaders::YouTube
    end

    it 'does not match other stuff' do
      loader = AssetHostCore::Loaders::YouTube.build_from_url('nope.com/nope')
      loader.should eq nil
    end
  end

  describe '#load' do
    before :each do
      FakeWeb.register_uri(:get, %r{googleapis\.com/discovery},
        content_type: "application/json", body: load_api_response('youtube/discovery.json'))

      FakeWeb.register_uri(:get, %r{googleapis\.com/youtube},
        content_type: "application/json", body: load_api_response('youtube/video.json'))

      FakeWeb.register_uri(:get, %r{i\.ytimg\.com},
        content_type: "image/jpeg", body: load_image('chipmunk.jpg'))

      @loader = AssetHostCore::Loaders::YouTube.build_from_url('http://www.youtube.com/watch?v=y8Kyi0WNg40')
      @asset  = @loader.load
    end

    it 'creates a new asset' do
      @asset.should be_a AssetHostCore::Asset
    end

    it 'sets the owner' do
      @asset.owner.should match /cregets/
    end

    it 'sets the title' do
      @asset.title.should eq "Dramatic Chipmunk"
    end

    it 'sets the caption' do
      @asset.caption.should match /best 5 second clip/
    end
  end
end
