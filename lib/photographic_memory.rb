require 'timeout'
require 'open3'
require 'digest'

class PhotographicMemory

  attr_accessor :bucket

  def initialize bucket
    @bucket = bucket
  end

  def put file:, id:, style_name:'original', convert_options: []
    unless style_name == 'original'
      output = render file, convert_options
    else
      output = file.read
    end 
    file.rewind
    digest   = Digest::MD5.hexdigest(file.read)
    key      = "#{id}_#{digest}_#{style_name}.jpg"
    bucket.object(key).put(body: output)
    digest
  end

  def get key
    bucket.object(key).get.body
  end

  def delete key
    bucket.object(key).delete
  end

  private

  def render file, convert_options=[]
    stdin, stdout, stderr, wait_thr = Open3.popen3(["convert", "-", convert_options, "jpeg:-"].flatten.join(" "))
    pid = wait_thr.pid

    Timeout.timeout(500) do
      stdin.puts file.read
      stdin.close

      output = []
      error  = []

      while (response = [stdout.gets, stderr.gets]) && response.compact.any?
        output << response[0]
        error  << response[1]
      end

      output.compact!
      error.compact!

      output = output.any? ? output.join('') : nil
      error  = error.any? ? error.join('') : nil

      unless error
        raise PhotographicMemoryError.new("No output received.") if output.empty?
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
