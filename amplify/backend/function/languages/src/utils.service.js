const AWS = require('aws-sdk');


function setupTranslateService(){
  AWS.config.update({ region: process.env.REGION || 'eu-central-1' });
  return  new AWS.Translate({});
}

exports.getSupportedLanguagesList = ()=> {
    const translateService = setupTranslateService();
    return translateService.listLanguages().promise();
}