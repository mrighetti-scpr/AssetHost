module ImageLoader
  def load_image(filename)
    File.read(File.join('spec', 'fixtures', 'images', filename))
  end
end
