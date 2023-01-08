/* Amplify Params - DO NOT EDIT
	API_ANIMEAL_GRAPHQLAPIENDPOINTOUTPUT
	API_ANIMEAL_GRAPHQLAPIIDOUTPUT
	API_ANIMEAL_GRAPHQLAPIKEYOUTPUT
	ENV
	REGION
Amplify Params - DO NOT EDIT */

const AWS = require('aws-sdk');
const parse = AWS.DynamoDB.Converter.unmarshall;

const {
  getAllLanguages,
  translate,
  updateCategory,
  getAllLanguagesSettings,
  updatePet,
  updateFeedingPoint,
  updateQuestion
} = require('./query');

const config = {
  Category: ['name'],
  Pet: ['name', 'breed', 'color'],
  FeedingPoint: [
    'name',
    'description',
    'city',
    'street',
    'address',
    'region',
    'neigborhood',
  ],
  Question: ['value', 'answer']
};

const API = {
  Category: updateCategory,
  Pet: updatePet,
  FeedingPoint: updateFeedingPoint,
  Question: updateQuestion
};

exports.handler = async (event) => {
  console.log(JSON.stringify(event, null, 2));
  const languagesSettings = await getAllLanguagesSettings();
  const defaultLanguage = languagesSettings.find(
    (lang) => lang.name === 'defaultLanguage',
  ).value;

  const languages = (await getAllLanguages()).filter(
    (it) => it.code !== defaultLanguage,
  );

  for (const record of event.Records) {
    const newImage = parse(record.dynamodb.NewImage);
    const fields = config[newImage.__typename] || [];

    const oldImage = parse(record.dynamodb.OldImage);
    const trackableEvents = ['MODIFY', 'INSERT'];
    const fieldsToUpdate = [];
    newImage.i18n = newImage.i18n || [];
    if (trackableEvents.includes(record.eventName)) {
      fields.forEach((field) => {
        if (
          !oldImage ||
          newImage[field] !== oldImage[field] ||
          languages.some((language) => {
            const translation = newImage.i18n.find(
              (it) => it.locale === language.code,
            );
            return (
              (translation && !translation[field] && newImage[field]) ||
              !translation
            );
          })
        ) {
          fieldsToUpdate.push(field);
        }
      });

      if (fieldsToUpdate.length) {
        for (const language of languages) {
          newImage.i18n = newImage.i18n || [];
          let locale = newImage.i18n.find((it) => it.locale === language.code);
          if (!locale) {
            locale = {
              locale: language.code,
            };
            newImage.i18n.push(locale);
          }

          for (fl of fieldsToUpdate) {
            if (newImage[fl]) {
              locale[fl] = (
                await translate({
                  text: newImage[fl],
                  to: language.code,
                  from: defaultLanguage,
                })
              ).data.data.translate;
            } else {
              locale[fl] = newImage[fl];
            }
          }
        }
        const { __typename, ...input } = newImage;
        const resp = await API[__typename]({ input });
        if (resp.data.errors) {
          Promise.resolve('Failed processed DynamoDB record');
        }
        console.log('Successfully processed and updated DynamoDB record');
      }
      return Promise.resolve(
        'Successfully processed and updated DynamoDB record',
      );
    }
  }
  console.log('Successfully processed DynamoDB record without an update');

  return Promise.resolve(
    'Successfully processed DynamoDB record without an update',
  );
};
