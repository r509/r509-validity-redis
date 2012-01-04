require "spec_helper"

describe R509::Validity::Redis::Checker do
    context "constructor" do
        it "when redis is nil" do
            expect { R509::Validity::Redis::Checker.new(nil) }.to raise_error(ArgumentError, "Redis must be provided")
        end
    end
    context "check" do
        it "throws an exception when issuer is nil/empty string" do
            redis = double("redis")
            checker = R509::Validity::Redis::Checker.new(redis)
            expect { checker.check(nil,123) }.to raise_error(ArgumentError, "Serial and issuer must be provided")
        end
        it "throws an exception when serial is nil/empty string" do
            redis = double("redis")
            checker = R509::Validity::Redis::Checker.new(redis)
            expect { checker.check("abcdef",nil) }.to raise_error(ArgumentError, "Serial and issuer must be provided")
        end
        it "gets unknown when serial is not found (returns {})" do
            redis = double("redis")
            checker = R509::Validity::Redis::Checker.new(redis)
            redis.should_receive(:hgetall).with("cert:abcdef:123").and_return({})
            status = checker.check("abcdef",123)
            status.status.should == R509::Validity::UNKNOWN
        end
        it "gets unknown when serial is not found (returns nil)" do
            redis = double("redis")
            checker = R509::Validity::Redis::Checker.new(redis)
            redis.should_receive(:hgetall).with("cert:abcdef:123").and_return(nil)
            status = checker.check("abcdef",123)
            status.status.should == R509::Validity::UNKNOWN
        end
        it "gets valid" do
            redis = double("redis")
            checker = R509::Validity::Redis::Checker.new(redis)
            redis.should_receive(:hgetall).with("cert:abcdef:123").and_return({"status" => "0" })
            status = checker.check("abcdef",123)
            status.status.should == R509::Validity::VALID
            status.revocation_time.should == 0
            status.revocation_reason.should == 0
        end
        it "gets revoked with revocation time and reason" do
            redis = double("redis")
            checker = R509::Validity::Redis::Checker.new(redis)
            redis.should_receive(:hgetall).with("cert:abcdef:123").and_return({"status" => "1", "revocation_time" => "789", "revocation_reason" => "5" })
            status = checker.check("abcdef",123)
            status.status.should == R509::Validity::REVOKED
            status.revocation_time.should == 789
            status.revocation_reason.should == 5
        end
    end
end
