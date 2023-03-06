
const _service = require('./utils.service.js');

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
exports.handler = async (event, context, callback) => {
    console.log(`EVENT: ${JSON.stringify(event)}`);

    try {
        const languagesList = await _service.getSupportedLanguagesList();
        callback(null, languagesList.Languages?.map((language) =>{
          return {code: language.LanguageCode, name: language.LanguageName}
        }));
      } catch (err) {
        callback(err);
      }
};
