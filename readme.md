# CommandBox AWS IMDS Expander Module

This module is intended to give access to AWS Instance Meta Data Service data within CommandBox using a custom **awsimds** [expansion namespace](https://commandbox.ortusbooks.com/usage/system-setting-expansion-namespaces).

## Usage

Within any of the places where you can use system setting expansion (e.g server.json) reference the IMDS variable you wish to retrieve by prefixing the variable name with `awsimds` - e.g. to access the `instance-id` of the host AWS EC2 instance, use `{awsimds.instance-id}`

Please note, value is cached on first lookup - so this is not currently suitable for referencing any IMDS values which may change through the application lifecycle.

Any lookup failures will be caught, and replaced with the default value passed in (empty string if nothing passed explicitly).

To set an explicit default value, use standard commandbox system expansion syntax - e.g `${awsimds.instance-id:No-AWS-Instance-Detected}`

Any lookup failures will log a warning via logbox (*Unable to retrieve **settingName** from AWS IMDS - Are you running within an AWS Instance???*)

Obviously... don't expect anything other than the default value to be achieved when not running in an AWS environment.

## IMDSv2

Version `2.0.0` uses IMDSv2 session tokens. The module first requests a token from `/latest/api/token` and then sends that token on metadata `GET` requests using the `X-aws-ec2-metadata-token` header.

The module also exposes a synthetic method value:

```json
"jvm": {
    "args": "-Dawsimds.method=${awsimds.method:IMDSUnavailable}"
}
```

When token-authenticated metadata lookup succeeds, `${awsimds.method:IMDSUnavailable}` resolves to `IMDSv2`. This can be used to make the metadata method visible in JVM/System information without changing FusionReactor server names or cloud groups.

When running inside a Docker container on EC2, confirm the instance metadata response hop limit is high enough for container access. A hop limit of `1` can prevent IMDSv2 token responses from reaching the container; use a container-safe setting such as `HttpPutResponseHopLimit=2` where required.

## Potential Future Improvements:

  * Currently an http call is made to the IMDS service endpoint for each unique setting.  If referencing multiple settings, it would be more efficient to retrieve the [Instance Identity Document](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-identity-documents.html) and populate the cahce structure in a single request

Pull Requests are welcome :)
