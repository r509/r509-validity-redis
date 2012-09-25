This project is related to [r509](http://github.com/reaperhulk/r509) and [ocsp-responder](http://github.com/reaperhulk/ocsp-responder), allowing certificate validity and revocation information to be read and written to a Redis backend.

When a certificate is issued, we want this sent to Redis:

    HMSET "cert:<serial>" status 0

When revoked:

    HMSET "cert:<serial>" status 1 revocation_time <timestamp> revocation_reason 0


To get the status of a certificate:

    HGETALL "cert:<serial>"

The "status" field can be one of:

    R509::Validity::VALID
    R509::Validity::REVOKED

The "revocation_reason" field can be one of:

    I don't know, we should probably find out

Use this in a project like ocsp-responder by passing it into R509::Ocsp::Signer's constructor:

    R509::Ocsp::Signer.new(
        :validity_checker => R509::Validity::Redis::Checker.new(Redis.new)
    )

