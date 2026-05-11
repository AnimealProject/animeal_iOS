/* Amplify Params - DO NOT EDIT
	API_ANIMEAL_FEEDINGCONSTRAINTTABLE_ARN
	API_ANIMEAL_FEEDINGCONSTRAINTTABLE_NAME
	API_ANIMEAL_FEEDINGTABLE_ARN
	API_ANIMEAL_FEEDINGTABLE_NAME
	API_ANIMEAL_GRAPHQLAPIENDPOINTOUTPUT
	API_ANIMEAL_GRAPHQLAPIIDOUTPUT
	API_ANIMEAL_GRAPHQLAPIKEYOUTPUT
	ENV
	REGION
Amplify Params - DO NOT EDIT */

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */

const AWS = require('aws-sdk');
const { rejectFeeding, checkActiveFeeding } = require('./query');

const dynamoDB = new AWS.DynamoDB.DocumentClient({});
const parse = AWS.DynamoDB.Converter.unmarshall;
const trackableEvents = ['REMOVE'];

exports.handler = async (event) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);

  // Time to Live (TTL) is used
  for (const record of event.Records) {
    if (!trackableEvents.includes(record.eventName)) {
      continue;
    }

    const oldImage = parse(record.dynamodb.OldImage);
    const isActive = await checkActiveFeeding(dynamoDB, oldImage.feedingPointFeedingsId, oldImage.id);
    if (!isActive) {
      console.log(
        `Feeding for feeding point (ID:${oldImage.feedingPointFeedingsId}) has been already processed, skipping...`,
      );
      continue;
    }

    const rejectFeedingRes = await rejectFeeding({
      feedingId: oldImage.feedingPointFeedingsId,
      reason:
        new Date(oldImage.expireAt * 1000).getTime() > new Date().getTime()
          ? 'Manual removing'
          : oldImage.status == 'pending'
          ? 'Approval time has expired'
          : 'Feeding time has expired',
      feeding: {
        id: oldImage.id,
        userId: oldImage.userId,
        images: oldImage.images,
        createdAt: oldImage.createdAt,
        updatedAt: oldImage.updatedAt,
        createdBy: oldImage.createdBy,
        updatedBy: oldImage.updatedBy,
        feedingPointDetails: oldImage.feedingPointDetails,
        assignedModerators: oldImage.assignedModerators,
        owner: oldImage.owner,
        feedingPointFeedingsId: oldImage.feedingPointFeedingsId,
      },
    });
    if (rejectFeedingRes.data?.errors?.length) {
      const error = JSON.stringify(rejectFeedingRes.data.errors);
      throw new Error(`Failed to Auto Reject feeding. Error:${error}`);
    }

    console.log(
      `Successfully Auto Reject record for feeding point (ID:${oldImage.feedingPointFeedingsId})`,
    );
  }
};
