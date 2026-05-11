/* Amplify Params - DO NOT EDIT
	API_ANIMEAL_FAVOURITETABLE_ARN
	API_ANIMEAL_FAVOURITETABLE_NAME
	API_ANIMEAL_GRAPHQLAPIIDOUTPUT
	ENV
	REGION
Amplify Params - DO NOT EDIT */

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */

const AWS = require('aws-sdk');
const { deleteFeedingPointFavourites } = require('./query');

const parse = AWS.DynamoDB.Converter.unmarshall;
const trackableEvents = ['REMOVE'];

exports.handler = async (event) => {
  try {
    console.log(`EVENT: ${JSON.stringify(event)}`);

    for (const record of event.Records) {
      if (!trackableEvents.includes(record.eventName)) {
        continue;
      }

      const oldImage = parse(record.dynamodb.OldImage);
      if (oldImage.__typename === 'FeedingPoint') {
        await deleteFeedingPointFavourites(oldImage.id);
      }
    }
  } catch (e) {
    return Promise.reject(`Failure during processing DynamoDB record: ${e}`);
  }

  return Promise.resolve('Successfully processed DynamoDB record');
};
