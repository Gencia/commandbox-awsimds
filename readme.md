# CommandBox AWS IMDS Expander Module

This module is intended to give access to AWS Instance Meta Data Service data within CommandBox using a custom **awsimds** [expansion namespace](https://commandbox.ortusbooks.com/usage/system-setting-expansion-namespaces).

## Usage

Within any of the places where you can use system setting expansion (e.g server.json) reference the IMDS variable you wish to retrieve by prefixing the variable name with `awsimds` - e.g. to access the instanceId of the hose AWS EC2 instance, use `{awsimds.instance-id}`

Please note, value is cached on first lookup - so this is not currently suitable for referencing any IMDS values which may change through the application lifecycle.

Any lookup failures will be caught, and replaced with the default value passed in (empty string if nothing passed explicitly).

To set an explicit default value, use standard commandbox system expansion syntax - e.g `${awsimds.instance-id:No-AWS-Instance-Detected}`

Any lookup failues will log a warning via logbox (*Unable to retrieve **settingName** from AWS IMDS - Are you running within an AWS Instance???*)

Obviously... don't expect anything other than the default value to be achieved when not running in an AWS environment.

This has been tested running within a Docker container within an Amazon Linux 2 EC2 environment - any other configurations are untested.

## Potential Future Improvements:

  * Currently an http call is made to the IMDS service endpoint for each unique setting.  If referencing multiple settings, it would be more efficient to retrieve the [Instance Identity Document](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-identity-documents.html) and populate the cahce structure in a single request
  * Currently only IMDSv1 is supported - so if only IMDSv2 is upported within you environment, values will not be retrieved. Consideration should be given to supporting IMDSv2 as per [AWS documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html)

Pull Requests are welcome :)
