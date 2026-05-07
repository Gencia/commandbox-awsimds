component {
    variables.cache = structNew();
    variables.token = '';
    variables.tokenExpiresAt = 0;
    variables.tokenTTLSeconds = 21600;
    variables.metadataBaseUrl = 'http://169.254.169.254/latest/meta-data/';
    variables.tokenUrl = 'http://169.254.169.254/latest/api/token';

    function onSystemSettingExpansion( required struct interceptData ) {
        if( interceptData.setting.lcase().startsWith( 'awsimds.' ) ) {
            var settingName = interceptData.setting.replaceNoCase( 'awsimds.', '', 'one' );
            if (!structKeyExists(variables.cache,settingName))
            {
                try {
                    if( compareNoCase( settingName, 'method' ) == 0 ) {
                        getMetadataValue( 'instance-id' );
                        variables.cache[settingName] = 'IMDSv2';
                    } else {
                        variables.cache[settingName] = getMetadataValue( settingName );
                    }

                    log.info('IMDSv2 meta data requested successfully for #settingName#');
                } 
                catch (exName) {
                    log.warn('Unable to retrieve #settingName# from AWS IMDS - Are you running within an AWS Instance???');
                    log.warn(exName.Message);
                    log.warn('Requested URL: ' & variables.metadataBaseUrl & settingName);
                    variables.cache[settingName] = interceptData.defaultValue;
                }
            }
            interceptData.setting = variables.cache[settingName];
            interceptData.resolved=true;
            return true;
        }
    }

    private string function getMetadataValue( required string settingName ) {
        var imdsURL = variables.metadataBaseUrl & arguments.settingName;
        var httpService = new http();
        httpService.setMethod("get");
        httpService.setUrl(imdsURL);
        httpService.settimeout(1);
        httpService.setthrowonerror(true);
        httpService.addParam(
            type="header",
            name="X-aws-ec2-metadata-token",
            value=getIMDSv2Token()
        );

        var serviceResponse = httpService.send().getPrefix();
        return serviceResponse.Filecontent;
    }

    private string function getIMDSv2Token() {
        var nowTick = getTickCount();
        var expiryBufferMs = 60000;

        if( len( variables.token ) && variables.tokenExpiresAt > ( nowTick + expiryBufferMs ) ) {
            return variables.token;
        }

        var httpService = new http();
        httpService.setMethod("put");
        httpService.setUrl(variables.tokenUrl);
        httpService.settimeout(1);
        httpService.setthrowonerror(true);
        httpService.addParam(
            type="header",
            name="X-aws-ec2-metadata-token-ttl-seconds",
            value=variables.tokenTTLSeconds
        );

        var serviceResponse = httpService.send().getPrefix();
        variables.token = serviceResponse.Filecontent;
        variables.tokenExpiresAt = nowTick + ( variables.tokenTTLSeconds * 1000 );

        return variables.token;
    }
}