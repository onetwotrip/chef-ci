require 'mixlib/cli'

##
# This class represents Knife options
class KnifeCliTemplate
  include Mixlib::CLI
end

KnifeCliTemplate.option(:yes, long: '--yes')
KnifeCliTemplate.option(:disable_editing, long: '--disable-editing', boolean: true)
