require 'mixlib/cli'
require 'open3'
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

  private

  def system_call(cmd)
    stdout, status = Open3.capture2e cmd
    raise stdout unless status.success?
    stdout
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
