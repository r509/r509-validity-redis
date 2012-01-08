require 'r509'

unless Kernel.respond_to?(:require_relative)
    module Kernel
        def require_relative(path)
            require File.join(File.dirname(caller[0]), path.to_str)
        end
    end
end

module R509::Validity::Redis
    require_relative('redis/checker.rb')
    require_relative('redis/writer.rb')
end

