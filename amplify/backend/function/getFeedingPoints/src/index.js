/* Amplify Params - DO NOT EDIT
	API_ANIMEAL_CATEGORYTABLE_ARN
	API_ANIMEAL_CATEGORYTABLE_NAME
	API_ANIMEAL_FAVOURITETABLE_ARN
	API_ANIMEAL_FAVOURITETABLE_NAME
	API_ANIMEAL_FEEDINGPOINTTABLE_ARN
	API_ANIMEAL_FEEDINGPOINTTABLE_NAME
	API_ANIMEAL_GRAPHQLAPIENDPOINTOUTPUT
	API_ANIMEAL_GRAPHQLAPIIDOUTPUT
	API_ANIMEAL_GRAPHQLAPIKEYOUTPUT
	API_ANIMEAL_RELATIONPETFEEDINGPOINTTABLE_ARN
	API_ANIMEAL_RELATIONPETFEEDINGPOINTTABLE_NAME
	API_ANIMEAL_RELATIONUSERFEEDINGPOINTTABLE_ARN
	API_ANIMEAL_RELATIONUSERFEEDINGPOINTTABLE_NAME
	ENV
	REGION
Amplify Params - DO NOT EDIT */

/**
 * @type {import('@types/aws-lambda').APIGatewayProxyHandler}
 */
const AWS = require('aws-sdk');

const dynamoDB = new AWS.DynamoDB.DocumentClient({});

const getFeedingPointIdsByModeratorId = async (moderatorId) => {
  const filter = ['userId = :moderatorId'];
  const values = { ':moderatorId': moderatorId };

  const scanParams = {
    TableName: process.env.API_ANIMEAL_RELATIONUSERFEEDINGPOINTTABLE_NAME,
    FilterExpression: filter.join(' AND '),
    ExpressionAttributeValues: values,
  };

  const feedinPointsRes = await dynamoDB.scan(scanParams).promise();
  return feedinPointsRes.Items.map((p) => p.feedingPointId);
};

const getCategoryIdsByTag = async (tag) => {
  const filter = ['tag = :tag'];
  const values = { ':tag': tag };

  const scanParams = {
    TableName: process.env.API_ANIMEAL_CATEGORYTABLE_NAME,
    FilterExpression: filter.join(' AND '),
    ExpressionAttributeValues: values,
  };

  const categoriesRes = await dynamoDB.scan(scanParams).promise();
  return categoriesRes.Items.map((p) => p.id);
};

exports.handler = async (event) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);

  if (!event?.identity?.username) {
    throw new Error('User is not authenticated');
  }

  const { moderatorId, categoryTag, locationBounds } = event.arguments;

  const filter = [];
  const values = {};
  const attributeNames = {};

  const isJustVolunteer = event.identity.groups.includes('Volunteer') &&
    event.identity.groups.length === 1;

  // moderatorId
  if (moderatorId) {
    const pointIds = await getFeedingPointIdsByModeratorId(moderatorId);
    const names = [];
    pointIds.forEach((id, i) => {
      const name = `:id${i}`;
      values[name] = id;
      names.push(name);
    });
    filter.push(`#id IN (${names.join(', ')})`);
    attributeNames['#id'] = 'id';
  }

  // locationBounds
  if (
    locationBounds &&
    locationBounds.bottom_right.lat &&
    locationBounds.bottom_right.lon &&
    locationBounds.top_left.lat &&
    locationBounds.top_left.lon
  ) {
    filter.push('#loc.#lat BETWEEN :minLat AND :maxLat');
    filter.push('#loc.#lon BETWEEN :minLon AND :maxLon');
    values[':minLat'] = locationBounds.bottom_right.lat;
    values[':maxLat'] = locationBounds.top_left.lat;
    values[':minLon'] = locationBounds.top_left.lon;
    values[':maxLon'] = locationBounds.bottom_right.lon;
    attributeNames['#loc'] = 'location';
    attributeNames['#lat'] = 'lat';
    attributeNames['#lon'] = 'lon';
  }

  // categoryTag
  if (categoryTag) {
    const categoryIds = await getCategoryIdsByTag(categoryTag);
    const names = [];
    categoryIds.forEach((id, i) => {
      const name = `:categoryId${i}`;
      values[name] = id;
      names.push(name);
    });
    filter.push(`feedingPointCategoryId IN (${names.join(', ')})`);
  }

  // hide disabled for volunteers 
  if (isJustVolunteer) {
    filter.push('#disabled <> :true');
    values[':true'] = true;
    attributeNames['#disabled'] = 'disabled';
  }

  try {
    const scanParams = {
      TableName: process.env.API_ANIMEAL_FEEDINGPOINTTABLE_NAME,
      FilterExpression: filter.length ? filter.join(' AND ') : null,
      ExpressionAttributeValues: Object.keys(values).length ? values : null,
      ExpressionAttributeNames: Object.keys(attributeNames).length
        ? attributeNames
        : null,
    };

    const feedinPointsRes = await dynamoDB.scan(scanParams).promise();
    return feedinPointsRes.Items;
  } catch (e) {
    throw new Error(`Failed to get Feeding points. Error: ${e.message}`);
  }
};
