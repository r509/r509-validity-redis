require "r509"

module R509ValidityRedis
    class Checker < R509::Validity::Checker
        def initialize(redis)
            raise ArgumentError.new("Redis must be provided") if redis.nil?
            @redis = redis
        end

        def check(serial)
            raise ArgumentError.new("Serial must be provided") if serial.nil? or serial.to_s.empty?

            hash = @redis.hgetall("cert:#{serial}")
            if not hash.nil? and hash.has_key?("status")
                R509::Validity::Status.new(
                    :status => hash["status"].to_i,
                    :revocation_time => hash["revocation_time"].to_i || nil,
                    :revocation_reason => hash["revocation_reason"].to_i || 0
                )
            else
                R509::Validity::Status.new(:status => R509::Validity::UNKNOWN)
            end
        end
    end
end
