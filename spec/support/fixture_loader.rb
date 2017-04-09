module FixtureLoader
  def load_image(filename)
    File.open(File.join('spec', 'fixtures', 'images', filename))
  end

  def load_api_response(filename)
    File.read(File.join('spec', 'fixtures', 'api', filename))
  end
end
