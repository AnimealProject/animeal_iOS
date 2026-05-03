/* Amplify Params - DO NOT EDIT
	API_ANIMEAL_FEEDINGCONSTRAINTTABLE_ARN
	API_ANIMEAL_FEEDINGCONSTRAINTTABLE_NAME
	API_ANIMEAL_FEEDINGHISTORYTABLE_ARN
	API_ANIMEAL_FEEDINGHISTORYTABLE_NAME
	API_ANIMEAL_FEEDINGPOINTTABLE_ARN
	API_ANIMEAL_FEEDINGPOINTTABLE_NAME
	API_ANIMEAL_FEEDINGTABLE_ARN
	API_ANIMEAL_FEEDINGTABLE_NAME
	API_ANIMEAL_GRAPHQLAPIENDPOINTOUTPUT
	API_ANIMEAL_GRAPHQLAPIIDOUTPUT
	API_ANIMEAL_GRAPHQLAPIKEYOUTPUT
	AUTH_ANIMEAL8F90E9B68F90E9B6_USERPOOLID
	ENV
	REGION
Amplify Params - DO NOT EDIT */

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */

const AWS = require('aws-sdk');
const {
  approveFeeding,
  getUser,
  updateFeedingAsPending,
  getActiveFeeding,
} = require('./query');

const dynamoDB = new AWS.DynamoDB.DocumentClient({});

exports.handler = async (event) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);

  const { feedingId: feedingPointId, images } = event.arguments;
  const maxImagesCount = process.env.MAX_IMAGES_COUNT || 3;

  try {
    if (!images || images.length < 1) {
      throw new Error('Images are required');
    }

    if (images.length > Number(maxImagesCount)) {
      throw new Error(`Maximum allowed number of images is ${maxImagesCount}`);
    }

    const feeding = await getActiveFeeding(dynamoDB, feedingPointId);

    if (
      event?.identity?.username &&
      feeding.userId !== event.identity.username
    ) {
      throw new Error('Just user who started the feeding can finish it');
    }

    await updateFeedingAsPending(dynamoDB, feeding, images);

    const isTrustedUser = event?.identity?.username
      ? (await getUser(event.identity.username)).UserAttributes?.find(
          (it) => it.Name === 'custom:trusted',
        )?.Value === 'true'
      : false;
    const autoApproveReason =
      process.env.IS_APPROVAL_ENABLED !== 'true'
        ? 'Feeding has been finished by user'
        : isTrustedUser
        ? 'Has been auto-approved for trusted user'
        : null;
    if (autoApproveReason) {
      const approveFeedingRes = await approveFeeding({
        feedingId: feedingPointId,
        reason: autoApproveReason,
      });

      if (approveFeedingRes.data?.errors?.length) {
        throw new Error(JSON.stringify(approveFeedingRes.data?.errors));
      }
    }
  } catch (e) {
    throw new Error(`Failed to Finish feeding. Error: ${e.message}`);
  }

  return feedingPointId;
};
