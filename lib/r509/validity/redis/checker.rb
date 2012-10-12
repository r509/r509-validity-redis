require "r509"

module R509::Validity::Redis
    class Checker < R509::Validity::Checker
        def initialize(redis)
            raise ArgumentError.new("Redis must be provided") if redis.nil?
            @redis = redis
        end

        # @return [R509::Validity::Status]
        def check(issuer,serial)
            raise ArgumentError.new("Serial and issuer must be provided") if serial.to_s.empty? or issuer.to_s.empty?

            hash = @redis.hgetall("cert:#{issuer}:#{serial}")
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

        def is_available?
            (@redis.ping == "PONG")? true : false
        end
    end
end
