require "spec_helper"

describe R509ValidityRedis::Checker do
    it "when redis is nil" do
        expect { R509ValidityRedis::Checker.new(nil) }.to raise_error(ArgumentError, "Redis must be provided")
    end
    it "throws an exception when serial is nil" do
        redis = double("redis")
        checker = R509ValidityRedis::Checker.new(redis)
        expect { checker.check(nil) }.to raise_error(ArgumentError, "Serial must be provided")
    end
    it "throws an exception when serial is empty string" do
        redis = double("redis")
        checker = R509ValidityRedis::Checker.new(redis)
        expect { checker.check("") }.to raise_error(ArgumentError, "Serial must be provided")
    end
    it "gets unknown when serial is not found (returns {})" do
        redis = double("redis")
        checker = R509ValidityRedis::Checker.new(redis)
        redis.should_receive(:hgetall).with("cert:123").and_return({})
        status = checker.check(123)
        status.status.should == R509::Validity::UNKNOWN
    end
    it "gets unknown when serial is not found (returns nil)" do
        redis = double("redis")
        checker = R509ValidityRedis::Checker.new(redis)
        redis.should_receive(:hgetall).with("cert:123").and_return(nil)
        status = checker.check(123)
        status.status.should == R509::Validity::UNKNOWN
    end
    it "gets valid" do
        redis = double("redis")
        checker = R509ValidityRedis::Checker.new(redis)
        redis.should_receive(:hgetall).with("cert:123").and_return({"status" => "0" })
        status = checker.check(123)
        status.status.should == R509::Validity::VALID
        status.revocation_time.should == 0
        status.revocation_reason.should == 0
    end
    it "gets revoked with revocation time and reason" do
        redis = double("redis")
        checker = R509ValidityRedis::Checker.new(redis)
        redis.should_receive(:hgetall).with("cert:123").and_return({"status" => "1", "revocation_time" => "789", "revocation_reason" => "5" })
        status = checker.check(123)
        status.status.should == R509::Validity::REVOKED
        status.revocation_time.should == 789
        status.revocation_reason.should == 5
    end
end
