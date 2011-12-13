require 'r509'

unless Kernel.respond_to?(:require_relative)
    module Kernel
        def require_relative(path)
            require File.join(File.dirname(caller[0]), path.to_str)
        end
    end
end

module R509ValidityRedis
    require_relative('r509-validity-redis/Checker.rb')
    require_relative('r509-validity-redis/Writer.rb')
end
