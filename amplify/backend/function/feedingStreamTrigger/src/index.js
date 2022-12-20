/* Amplify Params - DO NOT EDIT
	ENV
	REGION
	API_ANIMEAL_GRAPHQLAPIIDOUTPUT
	API_ANIMEAL_GRAPHQLAPIENDPOINTOUTPUT
	API_ANIMEAL_GRAPHQLAPIKEYOUTPUT
	IS_AUTO_APPROVAL_ENABLED
Amplify Params - DO NOT EDIT */

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
const AWS = require('aws-sdk');
const { rejectFeeding, approveFeeding } = require('./query');

const parse = AWS.DynamoDB.Converter.unmarshall;

exports.handler = async (event) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);
  for (const record of event.Records) {
    const oldImage = parse(record.dynamodb.OldImage);

    const trackableEvents = ['REMOVE'];
    if (
      trackableEvents.includes(record.eventName) &&
      oldImage.status === 'pending' &&
      process.env.IS_AUTO_APPROVAL_ENABLED === 'true'
    ) {
      const approveFeedingRes = await approveFeeding({
        feedingId: oldImage.id,
        feeding: {
          id: oldImage.id,
          userId: oldImage.userId,
          images: oldImage.images,
          createdAt: oldImage.createdAt,
          updatedAt: oldImage.updatedAt,
          createdBy: oldImage.createdBy,
          updatedBy: oldImage.updatedBy,
          owner: oldImage.owner,
          feedingPointFeedingsId: oldImage.feedingPointFeedingsId,
        },
      });

      if (approveFeedingRes.data?.errors?.length) {
        throw new Error('Failed to auto approve Feeding');
      }
      console.log('Successfully auto approved pending record');
    } else if (
      trackableEvents.includes(record.eventName) &&
      oldImage.status !== 'pending'
    ) {
      const rejectFeedingRes = await rejectFeeding({
        feedingId: oldImage.id,
        feeding: {
          id: oldImage.id,
          userId: oldImage.userId,
          images: oldImage.images,
          createdAt: oldImage.createdAt,
          updatedAt: oldImage.updatedAt,
          createdBy: oldImage.createdBy,
          updatedBy: oldImage.updatedBy,
          owner: oldImage.owner,
          feedingPointFeedingsId: oldImage.feedingPointFeedingsId,
        },
      });

      if (rejectFeedingRes.data?.errors?.length) {

        throw new Error('Failed to reject Feeding');
      }
      console.log('Successfully auto rejected pending record');
    }
  }
};
