require "r509"

module R509::Validity::Redis
    class Writer < R509::Validity::Writer
        def initialize(redis)
            raise ArgumentError.new("Redis must be provided") if redis.nil?
            @redis = redis
        end

        def issue(issuer_fingerprint, serial)
            raise ArgumentError.new("Serial and issuer fingerprint must be provided") if serial.to_s.empty? or issuer_fingerprint.to_s.empty?
            cert = @redis.hgetall("cert:#{issuer_fingerprint}:#{serial}")
            if cert.nil? or not cert.has_key?("status")
                @redis.hmset("cert:#{issuer_fingerprint}:#{serial}", "status", 0)
            else
                raise StandardError.new("Serial #{serial} for issuer #{issuer_fingerprint} is already present")
            end
        end

        def revoke(issuer_fingerprint, serial, revocation_time=Time.now.to_i, reason=0)
            raise ArgumentError.new("Serial and issuer fingerprint must be provided") if serial.to_s.empty? or issuer_fingerprint.to_s.empty?
            @redis.hmset("cert:#{issuer_fingerprint}:#{serial}",
                "status", 1,
                "revocation_time", revocation_time || Time.now.to_i,
                "revocation_reason", reason || 0
            )
        end

        def unrevoke(issuer_fingerprint, serial)
            raise ArgumentError.new("Serial and issuer fingerprint must be provided") if serial.to_s.empty? or issuer_fingerprint.to_s.empty?
            cert = @redis.hgetall("cert:#{issuer_fingerprint}:#{serial}")
            if cert.nil? or not cert.has_key?("status")
                raise StandardError.new("Serial #{serial} for issuer #{issuer_fingerprint} is not present")
            else
                @redis.hmset("cert:#{issuer_fingerprint}:#{serial}", "status", 0)
            end
        end
    end
end
