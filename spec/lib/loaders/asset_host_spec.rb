require 'spec_helper'

describe AssetHostCore::Loaders::AssetHost do
  describe '::try_url' do
    it "can load from an api url" do
      assethost_root = "#{Rails.application.config.assethost.server}#{AssetHostCore::Engine.mounted_path}"

      asset = create :asset
      loader = AssetHostCore::Loaders::AssetHost.try_url("#{assethost_root}/api/assets/#{asset.id}")
      loader.should_not eq nil
    end

    it "can load from asset's actual URL" do
      asset = create :asset, url: "http://a.scpr.org/i/b0d21881d4563e38bacbf068d27afc04/59661-small.jpg"
      loader = AssetHostCore::Loaders::AssetHost.try_url(asset.url)
      loader.should_not eq nil
    end

    it "returns nil if the URL doesn't match" do
      loader = AssetHostCore::Loaders::AssetHost.try_url("http://nope.com")
      loader.should eq nil
    end
  end


  describe '#load' do
    it "just finds the asset from the database and returns it" do
      asset = create :asset, url: "http://a.scpr.org/i/b0d21881d4563e38bacbf068d27afc04/59661-small.jpg"
      loader = AssetHostCore::Loaders::AssetHost.new(id: asset.id, url: asset.url)
      loader.load.should eq asset
    end
  end
end
