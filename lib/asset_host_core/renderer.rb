require "timeout"
require "open3"
require "digest"
require "rack/mime"
require "aws-sdk"
require "mini_exiftool"

##
# An image processing client that uses ImageMagick's convert and an AWS S3-like API for storage.
#

module AssetHostCore
  module Renderer

    class RenderError < StandardError; end

    begin
      options = {
        region:           ENV["ASSETHOST_S3_REGION"],
        endpoint:         ENV["ASSETHOST_S3_ENDPOINT"],
        force_path_style: ENV["ASSETHOST_S3_FORCE_PATH_STYLE"] || true,
        credentials: Aws::Credentials.new(
          ENV["ASSETHOST_S3_ACCESS_KEY_ID"],
          ENV["ASSETHOST_S3_SECRET_ACCESS_KEY"]
        ),
        stub_responses:    Rails.env.test?,
        signature_version: ENV["ASSETHOST_S3_SIGNATURE_VERSION"] || "s3"
      }.select{|k,v| !v.nil?}

      S3_CLIENT = Aws::S3::Client.new(options)
    rescue
    end

    begin
      REKOGNITION_CLIENT = Aws::Rekognition::Client.new({
        region: ENV["ASSETHOST_REKOGNITION_REGION"],
        credentials: Aws::Credentials.new(
          ENV["ASSETHOST_REKOGNITION_ACCESS_KEY_ID"],
          ENV["ASSETHOST_REKOGNITION_SECRET_ACCESS_KEY"]
        )
      })
    rescue
    end

    def self.put file:, id:, convert_options: [], classify: true, content_type:
      return if !S3_CLIENT
      unless convert_options.empty?
        if content_type.match "image/gif"
          # TEMPORARY (lyang): rendering gif is too slow. Disabling for now.
          # output = render_gif file, convert_options
          output = file.read
        else
          output = render_jpg file, convert_options
        end
      else
        output = file.read
      end
      file.rewind
      rendered_digest = Digest::MD5.hexdigest(output)
      extension       = Rack::Mime::MIME_TYPES.invert[content_type]
      key             = "#{id}_#{rendered_digest}#{extension}"
      S3_CLIENT.put_object({
        bucket: ENV["ASSETHOST_S3_BUCKET"],
        key: key,
        body: output,
        content_type: content_type
      })
      if classify && ENV["RAILS_ENV"] != "test"
        reference = StringIO.new render_jpg(file, ["-quality 10"])
        # 👆 this is a low quality reference image we generate
        # which is sufficient for classification purposes but
        # saves bandwidth and overcomes the file size limit
        # for Rekognition
        keywords = detect_labels reference
        gravity  = detect_gravity reference
      else
        keywords = []
        gravity  = "Center"
      end
      {
        fingerprint: rendered_digest,
        metadata:    exif(file),
        extension:   extension,
        filename:    key,
        keywords:    keywords,
        gravity:     gravity
      }
    end

    def self.get key
      return if !S3_CLIENT
      S3_CLIENT.get_object({
        bucket: ENV["ASSETHOST_S3_BUCKET"],
        key: key
      }).body
    end

    def self.delete key
      return if !S3_CLIENT
      S3_CLIENT.delete_object({
        bucket: ENV["ASSETHOST_S3_BUCKET"],
        key: key
      })
    end

    private

    def self.exif file
      file.rewind
      MiniExiftool.new(file, :replace_invalid_chars => "")    
    end

    def self.render_jpg file, convert_options=[]
      file.rewind
      run_command ["convert", "-", convert_options, "jpeg:-"].flatten.join(" "), file.read.force_encoding("UTF-8"), 30
    end

    def self.render_gif file, convert_options=[]
      opts = Array(convert_options).concat(["-coalesce", "-repage 0x0", "+repage", "-colors 64", "-layers optimize"])
      opts.each do |option|
        if option.match("-crop")
          option.concat " +repage"
        end
      end
      file.rewind
      run_command ["convert", "-", opts, "gif:-"].flatten.join(" "), file.read.force_encoding("UTF-8"), 60
    end

    def self.classify file
      file.rewind
      detect_labels file
    rescue Aws::Rekognition::Errors::ServiceError, Aws::Errors::MissingRegionError, Seahorse::Client::NetworkingError
      # This also is not worth crashing over
      []
    end

    def self.detect_gravity file
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

    def self.nearest_fifth num
      (num * 2).round / 2.0
    end

    def self.detect_labels file
      return [] if !defined?(REKOGNITION_CLIENT)
      file.rewind
      # get the original image from S3 and classify
      REKOGNITION_CLIENT.detect_labels({
        image: {
          bytes: file
        },
        max_labels: 123, 
        min_confidence: 73, 
      }).labels
    rescue Aws::Rekognition::Errors::ServiceError, Aws::Errors::MissingRegionError, Seahorse::Client::NetworkingError => e
      []
    end

    def self.detect_faces file
      return [] if !defined?(REKOGNITION_CLIENT)
      file.rewind
      # get the original image from S3 and classify
      REKOGNITION_CLIENT.detect_faces({
        image: {
          bytes: file
        },
        attributes: ["ALL"]
      }).face_details
    rescue Aws::Rekognition::Errors::ServiceError, Aws::Errors::MissingRegionError, Seahorse::Client::NetworkingError => e
      []
    end

    def self.run_command command, input, timeout = 15
      stdin, stdout, stderr, wait_thr = Open3.popen3(command)
      pid = wait_thr.pid

      Timeout.timeout(timeout) do
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
          raise RenderError, "No output received." if !output
        else
          raise RenderError, error
        end
        output
      end
    rescue Timeout::Error, Errno::EPIPE => e
      raise RenderError, e.message
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
end
