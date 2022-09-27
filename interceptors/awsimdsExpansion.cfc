component {
    variables.cache = structNew();

    function onSystemSettingExpansion( required struct interceptData ) {
        if( interceptData.setting.lcase().startsWith( 'awsimds.' ) ) {
            var settingName = interceptData.setting.replaceNoCase( 'awsimds.', '', 'one' );
            if (!structKeyExists(variables.cache,settingName))
            {
                try {
                    local.httpService = new http();
                    local.httpService.setMethod("get");
                    local.httpService.setUrl('http://169.254.169.254/latest/meta-data/' & settingName);
                    local.httpService.settimeout(1);
                    local.httpService.setthrowonerror(true);
                    local.serviceResponse = local.httpService.send().getPrefix();            
                    local.serviceResponseText = local.serviceResponse.Filecontent;

                    variables.cache[settingName] = local.serviceResponseText;
                } 
                catch (exName) {
                    log.warn('Unable to retrieve #settingName# from AWS IMDS - Are you running within an AWS Instance???');
                    log.warn(exName.Message);
                    variables.cache[settingName] = interceptData.defaultValue;
                }
            }
            interceptData.setting = variables.cache[settingName];
            interceptData.resolved=true;
            return true;
        }
    }
}