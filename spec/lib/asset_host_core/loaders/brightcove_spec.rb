require 'spec_helper'

describe AssetHostCore::Loaders::Brightcove do
  describe '::build_from_url' do
    it 'matches a brightcove key' do
      AssetHostCore::Loaders::Brightcove.build_from_url('brightcove:2396253845001').should be_a AssetHostCore::Loaders::Brightcove
    end

    it 'returns nil for invalid url' do
      AssetHostCore::Loaders::Brightcove.build_from_url('nope.com/nope').should eq nil
    end
  end

  describe '#load' do
    before :each do
      FakeWeb.register_uri(:get, %r{api\.brightcove\.com},
        content_type: "application/json", body: load_api_response('brightcove/video.json'))

      FakeWeb.register_uri(:get, %r{brightcove\.vo\.llnwd\.net},
        content_type: "image/jpeg", body: load_image('stars.jpg'))

      @loader = AssetHostCore::Loaders::Brightcove.build_from_url('brightcove:2396253845001')
      @asset  = @loader.load
    end

    it 'creates a new asset' do
      @asset.should be_a Asset
      @asset.persisted?.should eq true
    end

    it 'sets the native to be a vimeo video' do
      @asset.native.should be_a BrightcoveVideo
    end

    it 'sets the owner' do
      @asset.owner.should match /KPCC/
    end

    it 'sets the title' do
      @asset.title.should match /NEXT/
    end

    it 'sets the caption' do
      @asset.caption.should match /Dark Matter/
    end

    #NOTE reimplement with photographic memory
    # it 'sets the image' do
    #   @asset.image.should be_a Paperclip::Attachment
    # end

  end
end
