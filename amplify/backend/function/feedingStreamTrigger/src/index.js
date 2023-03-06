/* Amplify Params - DO NOT EDIT
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
const { rejectFeeding, approveFeeding } = require('./query');
const dynamoDB = new AWS.DynamoDB.DocumentClient({});

const parse = AWS.DynamoDB.Converter.unmarshall;

exports.handler = async (event) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);
  for (const record of event.Records) {
    const oldImage = parse(record.dynamodb.OldImage);
    const newImage = parse(record.dynamodb.NewImage);
    const trackableEvents = ['REMOVE'];
    const trackableEventsToProlongExpirationDate = ['MODIFY'];

    if (
      trackableEvents.includes(record.eventName) &&
      oldImage.status === 'pending' &&
      process.env.IS_AUTO_APPROVAL_ENABLED === 'true' &&
      new Date(oldImage.expireAt * 1000).getTime() < new Date().getTime()
    ) {
      const approveFeedingRes = await approveFeeding({
        feedingId: oldImage.id,
        reason: 'Has been auto approved',
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
      new Date(oldImage.expireAt * 1000).getTime() < new Date().getTime()
    ) {
      const rejectFeedingRes = await rejectFeeding({
        feedingId: oldImage.id,
        reason:
          oldImage.status == 'pending'
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
          owner: oldImage.owner,
          feedingPointFeedingsId: oldImage.feedingPointFeedingsId,
        },
      });

      if (rejectFeedingRes.data?.errors?.length) {
        throw new Error('Failed to reject Feeding');
      }
      console.log('Successfully auto rejected pending record');
    }

    if (
      trackableEventsToProlongExpirationDate.includes(record.eventName) &&
      newImage.status === 'pending'
    ) {
      try {
        const expireAt = new Date();
        expireAt.setTime(expireAt.getTime() + 11 * 60 * 60 * 1000);
        await dynamoDB
          .transactWrite({
            TransactItems: [
              {
                Update: {
                  ExpressionAttributeValues: {
                    ':expireAt': Math.floor(expireAt.getTime() / 1000),
                    ':date': new Date().toISOString(),
                  },
                  Key: {
                    id: oldImage.id,
                  },
                  TableName: process.env.API_ANIMEAL_FEEDINGTABLE_NAME,
                  UpdateExpression:
                    'SET expireAt = :expireAt, statusUpdatedAt = :date',
                },
              },
            ],
          })
          .promise();
        console.log(
          `Successfully increased expiration time for ${
            oldImage.id
          }. New expiration time is ${Math.floor(expireAt.getTime() / 1000)}`,
        );
      } catch (e) {
        throw new Error(
          `Failed to increase expiration date. Error: ${e.message}`,
        );
      }
    }
  }
};
