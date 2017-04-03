require 'timeout'
require 'open3'
require 'digest'
require 'rack/mime'

class PhotographicMemory

  class PhotographicMemoryError < StandardError; end

  attr_accessor :bucket

  def initialize bucket=nil
    @bucket = bucket
  end

  def put file:, id:, style_name:'original', convert_options: [], content_type:
    # content_type is required
    unless (style_name == 'original') || convert_options.empty? # we assume original *means* original
      output = render file, convert_options
    else
      output = file.read
    end
    file.rewind
    original_digest   = Digest::MD5.hexdigest(file.read)
    rendered_digest   = Digest::MD5.hexdigest(output)
    extension = Rack::Mime::MIME_TYPES.invert[content_type]
    key       = "#{id}_#{original_digest}_#{style_name}#{extension}"
    bucket.object(key).put(body: output, content_type: content_type)
    if style_name == 'original'
      keywords = classify file
    else
      keywords = []
    end
    {
      fingerprint: rendered_digest,
      metadata: exif(file),
      key: key,
      extension: extension,
      keywords: keywords
    }
  end

  def get key
    bucket.object(key).get.body
  end

  def delete key
    bucket.object(key).delete
  end

  # def exif file
  #   file.rewind
  #   run_command "exiftool -json - ", file.read.force_encoding("UTF-8")
  # end

  private

  def exif file
    file.rewind
    MiniExiftool.new(file, :replace_invalid_chars => "")    
  end

  def render file, convert_options=[]
    file.rewind
    run_command ["convert", "-", convert_options, "jpeg:-"].flatten.join(" "), file.read
  end

  def classify file
    file.rewind
    # get the original image from S3 and classify
    client = Aws::Rekognition::Client.new region: 'us-west-2'

    resp = client.detect_labels({
      image: {
        bytes: file
      },
      max_labels: 123, 
      min_confidence: 70, 
    })

    resp.labels

  rescue Aws::Rekognition::Errors::ServiceError => e
    # This also is not worth crashing over
    []
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
