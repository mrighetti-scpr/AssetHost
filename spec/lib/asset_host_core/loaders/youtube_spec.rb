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

      @loader = AssetHostCore::Loaders::YouTube.build_from_url('http://www.youtube.com/watch?v=y8Kyi0WNg40?ah-noTrim')
    end

    it 'creates a new asset' do
      asset  = @loader.load
      asset.should be_a Asset
      asset.persisted?.should eq true
    end

    it 'sets the native to be a youtube video' do
      asset  = @loader.load
      asset.native.should be_a YoutubeVideo
    end

    it 'sets the owner' do
      asset  = @loader.load
      asset.owner.should match /cregets/
    end

    it 'sets the title' do
      asset  = @loader.load
      asset.title.should eq "Dramatic Chipmunk"
    end

    it 'sets the caption' do
      asset  = @loader.load
      asset.caption.should match /best 5 second clip/
    end

    it 'sets the image' do
      asset  = @loader.load
      # asset.image.should be_a Paperclip::Attachment
    end

    #NOTE Reimplement these without Paperclip::Trimmer
    # it 'trims letterboxing by default' do
    #   loader = AssetHostCore::Loaders::YouTube.build_from_url('http://www.youtube.com/watch?v=y8Kyi0WNg40')
    #   Paperclip::Trimmer.should_receive(:make).and_return(load_image('chipmunk.jpg'))
    #   loader.load
    # end

    # it 'does not trim if requested' do
    #   no_trim_loader = AssetHostCore::Loaders::YouTube.build_from_url('http://www.youtube.com/watch?v=y8Kyi0WNg40?ah-noTrim')
    #   Paperclip::Trimmer.should_not_receive(:make)
    #   no_trim_loader.load
    # end
  end
end
