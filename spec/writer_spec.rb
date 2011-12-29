require "spec_helper"

describe R509::Validity::Redis::Writer do
    context "constructor" do
        it "when redis is nil" do
            expect { R509::Validity::Redis::Writer.new(nil) }.to raise_error(ArgumentError, "Redis must be provided")
        end
    end

    context "issue" do
        it "when serial is nil" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            expect { writer.issue(nil) }.to raise_error(ArgumentError, "Serial must be provided")
        end
        it "when serial is empty string" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            expect { writer.issue("") }.to raise_error(ArgumentError, "Serial must be provided")
        end
        it "when serial is provided (check returns nil)" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            redis.should_receive(:hgetall).with("cert:123").and_return(nil)
            redis.should_receive(:hmset).with("cert:123", "status", 0)
            writer.issue(123)
        end
        it "when serial is provided (check returns {})" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            redis.should_receive(:hgetall).with("cert:123").and_return({})
            redis.should_receive(:hmset).with("cert:123", "status", 0)
            writer.issue(123)
        end
        it "when serial is already present" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            redis.should_receive(:hgetall).with("cert:123").and_return({"status"=>0})
            expect { writer.issue(123) }.to raise_error(StandardError, "Serial 123 is already present")
        end
    end

    context "revoke" do
        it "when serial is nil" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            expect { writer.revoke(nil) }.to raise_error(ArgumentError, "Serial must be provided")
        end
        it "when serial is empty string" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            expect { writer.revoke("") }.to raise_error(ArgumentError, "Serial must be provided")
        end
        it "when time and reason aren't provided" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            redis.should_receive(:hmset).with("cert:123", "status", 1, "revocation_time", Time.now.to_i, "revocation_reason", 0)
            writer.revoke(123)
        end
        it "when time and reason are nil" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            redis.should_receive(:hmset).with("cert:123", "status", 1, "revocation_time", Time.now.to_i, "revocation_reason", 0)
            writer.revoke(123, nil, nil)
        end
        it "when time is provided, but not reason" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            redis.should_receive(:hmset).with("cert:123", "status", 1, "revocation_time", 100, "revocation_reason", 0)
            writer.revoke(123, 100)
        end
        it "when time and reason are provided" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            redis.should_receive(:hmset).with("cert:123", "status", 1, "revocation_time", 100, "revocation_reason", 2)
            writer.revoke(123, 100, 2)
        end
    end

    context "unrevoke" do
        it "when serial is nil" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            expect { writer.unrevoke(nil) }.to raise_error(ArgumentError, "Serial must be provided")
        end
        it "when serial is empty string" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            expect { writer.unrevoke("") }.to raise_error(ArgumentError, "Serial must be provided")
        end
        it "when serial is provided" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            redis.should_receive(:hgetall).with("cert:123").and_return({"status" => 1})
            redis.should_receive(:hmset).with("cert:123", "status", 0)
            writer.unrevoke(123)
        end
        it "when cert record doesn't exist (nil)" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            redis.should_receive(:hgetall).with("cert:123").and_return(nil)
            expect { writer.unrevoke(123) }.to raise_error(StandardError, "Serial 123 is not present")
        end
        it "when cert record doesn't exist ({})" do
            redis = double("redis")
            writer = R509::Validity::Redis::Writer.new(redis)
            redis.should_receive(:hgetall).with("cert:123").and_return({})
            expect { writer.unrevoke(123) }.to raise_error(StandardError, "Serial 123 is not present")
        end
    end
end
