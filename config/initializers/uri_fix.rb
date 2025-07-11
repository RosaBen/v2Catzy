# Fix for URI gem compatibility issue with Ruby 3.4+
if RUBY_VERSION >= "3.4.0"
  require 'uri'
  
  # Patch URI::Generic to handle Hash hostname properly
  module URI
    class Generic
      alias_method :original_hostname=, :hostname=
      
      def hostname=(v)
        if v.is_a?(Hash)
          # Convert Hash to string representation or extract meaningful value
          v = v.to_s
        end
        original_hostname=(v)
      end
    end
  end
end
