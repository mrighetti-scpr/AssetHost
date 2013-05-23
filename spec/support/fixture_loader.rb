module FixtureLoader
  def load_image(filename)
    File.read(File.expand_path("../fixtures/images/#{filename}", File.dirname(__FILE__)))
  end

  def load_api_response(filename)
    File.read(File.expand_path("../fixtures/api/#{filename}", File.dirname(__FILE__)))
  end
end
