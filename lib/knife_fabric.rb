require 'mixlib/cli'
require 'sourcify'

##
# This class represets common knife methods
class KnifeFabric
  ##
  # This class represents Knife options
  class KnifeCliTemplate
    include Mixlib::CLI
  end
  KnifeCliTemplate.option(:yes, long: '--yes')
  KnifeCliTemplate.option(:disable_editing, long: '--disable-editing', boolean: true)
  HandleExceptions = [RuntimeError, SystemExit, StandardError].freeze

  attr_reader :status
  attr_accessor :logfile

  def logfile
    @logfile || 'logs/logfile.log'
  end

  private

  def run_with_log(cmd)
    io = File.open(logfile, 'w')
    status = system(cmd, out: io, err: io)
    io.close
    status
  end

  def run_with_out(cmd)
    r, io = IO.pipe
    system(cmd, out: io, err: io)
    io.close
    r.read
  end

  def rescue_knife(&block)
    yield(block)
  rescue *HandleExceptions => e
    puts "[ERROR] Failed on:\n#{block.to_source.split("\n").map { |l| "[ERROR] #{l}" }.join("\n")}"
    puts "[ERROR] Catch exception of type: #{e.class}\n#{e.message}"
    @status = false
  else
    @status = true
  end
end
