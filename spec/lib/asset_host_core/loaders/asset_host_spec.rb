require 'spec_helper'

describe AssetHostCore::Loaders::AssetHost do
  describe '::build_from_url' do
    it "can load from an api url" do
      asset = create :asset
      loader = AssetHostCore::Loaders::AssetHost.build_from_url("http://examplehost/api/assets/#{asset.id}")
      loader.should_not eq nil
    end

    it "can load from asset's actual URL" do
      asset = create :asset, url: "http://examplehost/i/b0d21881d4563e38bacbf068d27afc04/59661-small.jpg"
      loader = AssetHostCore::Loaders::AssetHost.build_from_url(asset.url)
      loader.should_not eq nil
    end

    it "returns nil if the URL doesn't match" do
      loader = AssetHostCore::Loaders::AssetHost.build_from_url("http://nope.com")
      loader.should eq nil
    end
  end

  describe '#load' do
    it "just finds the asset from the database and returns it" do
      asset = create :asset, url: "http://examplehost/i/b0d21881d4563e38bacbf068d27afc04/59661-small.jpg"
      loader = AssetHostCore::Loaders::AssetHost.new(id: asset.id, url: asset.url)
      loader.load.should eq asset
    end
  end
end
