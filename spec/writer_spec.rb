require "spec_helper"

describe R509::Validity::Redis::Writer do
    context "constructor" do
        it "when redis is nil" do
            expect { R509::Validity::Redis::Writer.new(nil) }.to raise_error(ArgumentError, "Redis must be provided")
        end
    end

    context "issue" do
        it "when issuer is nil/empty string" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            expect { writer.issue(nil,123) }.to raise_error(ArgumentError, "Serial and issuer must be provided")
        end
        it "when serial is nil/empty string" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            expect { writer.issue("abcdef",nil) }.to raise_error(ArgumentError, "Serial and issuer must be provided")
        end
        it "when serial/issuer is provided (check returns nil)" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            redis.should_receive(:hgetall).with("cert:abcdef:123").and_return(nil)
            redis.should_receive(:hmset).with("cert:abcdef:123", "status", 0)
            writer.issue("abcdef",123)
        end
        it "when serial/issuer is provided (check returns {})" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            redis.should_receive(:hgetall).with("cert:abcdef:123").and_return({})
            redis.should_receive(:hmset).with("cert:abcdef:123", "status", 0)
            writer.issue("abcdef",123)
        end
        it "when serial/issuer is already present" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            redis.should_receive(:hgetall).with("cert:abcdef:123").and_return({"status"=>0})
            expect { writer.issue("abcdef",123) }.to raise_error(StandardError, "Serial 123 for issuer abcdef is already present")
        end
    end

    context "revoke" do
        it "when issuer is nil/empty string" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            expect { writer.revoke(nil,123) }.to raise_error(ArgumentError, "Serial and issuer must be provided")
        end
        it "when serial is nil/empty string" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            expect { writer.revoke("abcdef",nil) }.to raise_error(ArgumentError, "Serial and issuer must be provided")
        end
        it "when time and reason aren't provided" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            redis.should_receive(:hmset).with("cert:abcdef:123", "status", 1, "revocation_time", Time.now.to_i, "revocation_reason", 0)
            writer.revoke("abcdef",123)
        end
        it "when time and reason are nil" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            redis.should_receive(:hmset).with("cert:abcdef:123", "status", 1, "revocation_time", Time.now.to_i, "revocation_reason", 0)
            writer.revoke("abcdef",123, nil, nil)
        end
        it "when time is provided, but not reason" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            redis.should_receive(:hmset).with("cert:abcdef:123", "status", 1, "revocation_time", 100, "revocation_reason", 0)
            writer.revoke("abcdef",123, 100)
        end
        it "when time and reason are provided" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            redis.should_receive(:hmset).with("cert:abcdef:123", "status", 1, "revocation_time", 100, "revocation_reason", 2)
            writer.revoke("abcdef",123, 100, 2)
        end
    end

    context "unrevoke" do
        it "when issuer is nil/empty string" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            expect { writer.unrevoke(nil,123) }.to raise_error(ArgumentError, "Serial and issuer must be provided")
        end
        it "when serial is nil/empty string" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            expect { writer.unrevoke("abcdef",nil) }.to raise_error(ArgumentError, "Serial and issuer must be provided")
        end
        it "when serial/issuer is provided" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            redis.should_receive(:hgetall).with("cert:abcdef:123").and_return({"status" => 1})
            redis.should_receive(:hmset).with("cert:abcdef:123", "status", 0)
            writer.unrevoke("abcdef",123)
        end
        it "when cert record doesn't exist (nil)" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            redis.should_receive(:hgetall).with("cert:abcdef:123").and_return(nil)
            expect { writer.unrevoke("abcdef",123) }.to raise_error(StandardError, "Serial 123 for issuer abcdef is not present")
        end
        it "when cert record doesn't exist ({})" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            redis.should_receive(:hgetall).with("cert:abcdef:123").and_return({})
            expect { writer.unrevoke("abcdef",123) }.to raise_error(StandardError, "Serial 123 for issuer abcdef is not present")
        end
    end
end
