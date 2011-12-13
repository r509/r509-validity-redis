require "r509"

module R509::Validity::Redis
    class Writer < R509::Validity::Writer
        def initialize(redis)
            raise ArgumentError.new("Redis must be provided") if redis.nil?
            @redis = redis
        end

        def issue(serial)
            raise ArgumentError.new("Serial must be provided") if serial.nil? or serial.to_s.empty?
            @redis.hmset("cert:#{serial}", "status", 0)
        end

        def revoke(serial, reason=0)
            raise ArgumentError.new("Serial must be provided") if serial.nil? or serial.to_s.empty?
            @redis.hmset("cert:#{serial}", 
                "status", 1, 
                "revocation_time", Time.now.to_i, 
                "revocation_reason", reason
            )
        end
    end
end
