require 'timeout'
require 'open3'
require 'digest'
require 'rack/mime'

class PhotographicMemory

  class PhotographicMemoryError < StandardError; end

  def initialize
    options = {
      region: Rails.application.secrets.s3['region'],
      endpoint: Rails.application.secrets.s3['endpoint'],
      credentials: Aws::Credentials.new(
        Rails.application.secrets.s3['access_key_id'], 
        Rails.application.secrets.s3['secret_access_key']
      ),
      stub_responses: Rails.env.test?
    }.select{|k,v| !v.nil?}
    @s3_client = Aws::S3::Client.new(options)
  end

  def put file:, id:, style_name:'original', convert_options: [], content_type:
    # content_type is required
    unless (style_name == 'original') || convert_options.empty? # we assume original *means* original
      if content_type.match "image/gif"
        output = render_gif file, convert_options
      else
        output = render file, convert_options
      end
    else
      output = file.read
    end
    file.rewind
    original_digest   = Digest::MD5.hexdigest(file.read)
    rendered_digest   = Digest::MD5.hexdigest(output)
    extension         = Rack::Mime::MIME_TYPES.invert[content_type]
    key       = "#{id}_#{original_digest}_#{style_name}#{extension}"
    # key       = "#{id}_#{original_digest}_#{style_name}.jpg"
    # ^^ Apparently, we always convert to jpg.  Maybe we won't always do this in the future?
    # bucket.object(key).put(body: output, content_type: content_type)
    @s3_client.put_object({
      bucket: Rails.application.secrets.s3['bucket'], 
      key: key, 
      body: output,
      content_type: content_type
    })
    if style_name == 'original'
      reference = StringIO.new render(file, ["-quality 10"])
      # 👆 this is a low quality reference image we generate
      # which is sufficient for classification purposes but
      # saves bandwidth and overcomes the file size limit
      # for Rekognition
      keywords = classify reference
      gravity  = detect_gravity reference
    else
      keywords = []
      gravity  = nil
    end

    {
      fingerprint: rendered_digest,
      metadata: exif(file),
      key: key,
      extension: extension,
      keywords: keywords,
      gravity: gravity
    }
  end

  def get key
    @s3_client.get_object({
      bucket: Rails.application.secrets.s3['bucket'],
      key: key
    }).body
  end

  def delete key
    @s3_client.delete_object({
      bucket: Rails.application.secrets.s3['bucket'],
      key: key
    })
  end

  private

  def exif file
    file.rewind
    MiniExiftool.new(file, :replace_invalid_chars => "")    
  end

  def render file, convert_options=[]
    file.rewind
    run_command ["convert", "-", convert_options, "jpeg:-"].flatten.join(" "), file.read.force_encoding("UTF-8")
  end

  def render_gif file, convert_options=[]
    convert_options.reject!{|o| o.match("-quality")}
    convert_options.concat(["-coalesce", "-repage 0x0", "+repage"])
    convert_options.each do |option|
      if option.match("-crop")
        option.concat " +repage"
      end
    end
    file.rewind
    run_command ["convert", "-", convert_options, "gif:-"].flatten.join(" "), file.read.force_encoding("UTF-8")
  end

  def pixels file
    results = run_command "convert - -depth 8  txt:-", file.read
    results.split("\n").map{|line| (line.split(" ")[1] || "0,0,0,1").split(",").map(&:to_i) }
  end

  def classify file
    return [] if Rails.env.test? # should work on stubbing responses instead of this
    file.rewind

    @labels ||= detect_labels file
    @faces  ||= detect_faces file

    # byebug

    @labels
  rescue Aws::Rekognition::Errors::ServiceError, Aws::Errors::MissingRegionError => e
    # This also is not worth crashing over
    []
  end

  def detect_gravity file
    file.rewind

    boxes = detect_faces(file).map(&:bounding_box)

    box = boxes.max_by{|b| b.width * b.height } # use the largest face in the photo

    return "Center" if !box

    x = nearest_fifth((box.width / 2)   + ((box.left >= 0) ? box.left : 0))
    y = nearest_fifth((box.height / 2)  + ((box.top  >= 0) ? box.top  : 0))

    gravity_table = {
      0.0 => {
        0.0 => "NorthWest",
        0.5 => "West",
        1.0 => "SouthWest"
      },
      0.5 => {
        0.0 => "North",
        0.5 => "Center",
        1 => "South"
      },
      1.0 => {
        0.0 => "NorthEast",
        0.5 => "East",
        1.0 => "SouthEast"
      }
    }

    gravity_table[x][y]
  end

  def nearest_fifth num
    (num * 2).round / 2.0
  end

  def detect_labels file
    file.rewind
    # get the original image from S3 and classify
    client = Aws::Rekognition::Client.new({
      region: Rails.application.secrets.rekognition['region'],
      credentials: Aws::Credentials.new(
        Rails.application.secrets.rekognition['access_key_id'],
        Rails.application.secrets.rekognition['secret_access_key']
      )
    })

    @labels ||= client.detect_labels({
      image: {
        bytes: file
      },
      max_labels: 123, 
      min_confidence: 80, 
    }).labels
  end

  def detect_faces file
    file.rewind
    # get the original image from S3 and classify
    client = Aws::Rekognition::Client.new({
      region: Rails.application.secrets.rekognition['region'],
      credentials: Aws::Credentials.new(
        Rails.application.secrets.rekognition['access_key_id'],
        Rails.application.secrets.rekognition['secret_access_key']
      )
    })
    @faces ||= client.detect_faces({
      image: {
        bytes: file
      },
      attributes: ["ALL"]
    }).face_details
  end

  def run_command command, input
    stdin, stdout, stderr, wait_thr = Open3.popen3(command)
    pid = wait_thr.pid

    Timeout.timeout(10) do # cancel in 10 seconds
      stdin.write input
      stdin.close

      output_buffer = []
      error_buffer  = []

      while (output_chunk = stdout.gets) || (error_chunk = stderr.gets)
        output_buffer << output_chunk
        error_buffer  << error_chunk
      end

      output_buffer.compact!
      error_buffer.compact!

      output = output_buffer.any? ? output_buffer.join('') : nil
      error  = error_buffer.any? ? error_buffer.join('') : nil

      unless error
        raise PhotographicMemoryError.new("No output received.") if !output
        return output
      else
        raise PhotographicMemoryError.new(error)
      end
    end
  rescue Timeout::Error, PhotographicMemoryError, Errno::EPIPE => e
    e
  ensure
    begin
      Process.kill("KILL", pid) if pid
    rescue Errno::ESRCH
      # Process is already dead so do nothing.
    end
    stdin  = nil
    stdout = nil
    stderr = nil
    wait_thr.value if wait_thr # Process::Status object returned.
  end
end

