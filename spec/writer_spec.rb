require "spec_helper"

describe R509ValidityRedis::Writer do
    context "constructor" do
        it "when redis is nil" do
            expect { R509ValidityRedis::Writer.new(nil) }.to raise_error(ArgumentError, "Redis must be provided")
        end
    end

    context "issue" do
        it "when serial is nil" do
            redis = double("redis")
            writer = R509ValidityRedis::Writer.new(redis)
            expect { writer.issue(nil) }.to raise_error(ArgumentError, "Serial must be provided")
        end
        it "when serial is empty string" do
            redis = double("redis")
            writer = R509ValidityRedis::Writer.new(redis)
            expect { writer.issue("") }.to raise_error(ArgumentError, "Serial must be provided")
        end
        it "when serial is provided" do
            redis = double("redis")
            writer = R509ValidityRedis::Writer.new(redis)
            redis.should_receive(:hmset).with("cert:123", "status", 0)
            writer.issue(123)
        end
    end

    context "revoke" do
        it "when serial is nil" do
            redis = double("redis")
            writer = R509ValidityRedis::Writer.new(redis)
            expect { writer.revoke(nil) }.to raise_error(ArgumentError, "Serial must be provided")
        end
        it "when serial is empty string" do
            redis = double("redis")
            writer = R509ValidityRedis::Writer.new(redis)
            expect { writer.revoke("") }.to raise_error(ArgumentError, "Serial must be provided")
        end
        it "when reason isn't provided" do
            redis = double("redis")
            writer = R509ValidityRedis::Writer.new(redis)
            redis.should_receive(:hmset).with("cert:123", "status", 1, "revocation_time", Time.now.to_i, "revocation_reason", 0)
            writer.revoke(123)
        end
        it "when reason is nil" do
            redis = double("redis")
            writer = R509ValidityRedis::Writer.new(redis)
            redis.should_receive(:hmset).with("cert:123", "status", 1, "revocation_time", Time.now.to_i, "revocation_reason", 0)
            writer.revoke(123)
        end
        it "when reason is provided" do
            redis = double("redis")
            writer = R509ValidityRedis::Writer.new(redis)
            redis.should_receive(:hmset).with("cert:123", "status", 1, "revocation_time", Time.now.to_i, "revocation_reason", 2)
            writer.revoke(123, 2)
        end
    end
end
