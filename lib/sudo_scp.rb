require "net/scp"

module Net
  class SCP
    module Sudo
      def scp_command(*args)
        command = super
        "sudo " + command
      end
    end
  end
end

Net::SCP.prepend Net::SCP::Sudo
