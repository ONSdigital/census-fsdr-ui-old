require_relative '../lib/core_ext/nilclass'
require_relative '../lib/core_ext/string'
require_relative '../lib/core_ext/object'

logger = Syslog::Logger.new(PROGRAM, Syslog::LOG_USER)

helpers do
  def url_format(str)
    str.gsub(/\s+/, '').downcase
  end
end
