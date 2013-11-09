require 'spec_helper'

describe AssetHostCore::Loaders::Flickr do
  describe '::build_from_url' do
    it 'matches flickr urls and returns a new loader' do
      loader = AssetHostCore::Loaders::Flickr.build_from_url("http://www.flickr.com/photos/kpcc/123")
      loader.should be_a AssetHostCore::Loaders::Flickr
      loader.id.should eq "123"

      loader = AssetHostCore::Loaders::Flickr.build_from_url("http://staticflickr.com/999/456_abc")
      loader.should be_a AssetHostCore::Loaders::Flickr
      loader.id.should eq "456"
    end

    it "returns nil if the URL doesn't match" do
      loader = AssetHostCore::Loaders::Flickr.build_from_url("http://nope.nope/nope")
      loader.should eq nil
    end

    it 'returns nil if flickr key is not set' do
      AssetHostCore.config.stub(:flickr_api_key) { nil }
      loader = AssetHostCore::Loaders::Flickr.build_from_url("http://staticflickr.com/999/456_abc")

      loader.should eq nil
    end
  end


  describe '#load' do
    context 'flickr success' do
      before :each do
        FakeWeb.register_uri(:get, %r{flickr\.photos\.getInfo},
          content_type: "application/json", body: load_api_response('flickr/photos_getInfo.json'))

        FakeWeb.register_uri(:get, %r{flickr\.photos\.getSizes},
          content_type: "application/json", body: load_api_response('flickr/photos_getSizes.json'))

        FakeWeb.register_uri(:get, %r{flickr\.photos\.licenses\.getInfo},
          content_type: "application/json", body: load_api_response('flickr/photos_licenses_getInfo.json'))

        FakeWeb.register_uri(:get, %r{staticflickr},
          content_type: "image/jpeg", body: load_image('hat.jpg'))
      end


      it 'gets the image information from flickr' do
        loader  = AssetHostCore::Loaders::Flickr.new(url: "http://staticflickr.com/999/456_abc", id: "456")
        asset   = loader.load

        asset.title.should eq "John's Wayne cowboy hat"
        asset.caption.should eq "This is a cowboy hat."
        asset.owner.should eq "AudioVision"
      end

      it "uses the last size as the source image" do
        loader  = AssetHostCore::Loaders::Flickr.new(url: "http://staticflickr.com/999/456_abc", id: "456")
        loader.should_receive(:image_file).with("http://farm7.staticflickr.com/6112/6238340909_234e5623a1_o.jpg")
        loader.load
      end
    end

    context 'flickr failure' do
      it "returns nil if photo isn't present" do
        FakeWeb.register_uri(:get, %r{flickr\.photos\.getInfo},
          content_type: "application/json", body: {}.to_json)

        loader  = AssetHostCore::Loaders::Flickr.new(url: "http://static.flickr.com/999/456_abc", id: "456")
        loader.load.should eq nil
      end
    end
  end
end
