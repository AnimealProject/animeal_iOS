const digitGenerator = require('crypto-secure-random-digit');
const AWS = require('aws-sdk');
const sns = new AWS.SNS();

async function sendChallengeCode(phoneNumber, passCode) {
  const params = {
    Message: 'Your secret code: ' + passCode,
    PhoneNumber: phoneNumber,
  };
  await sns.publish(params).promise();
}

async function createAuthChallenge(event) {
  console.log('RECEIVED Event: ', JSON.stringify(event, null, 2));
  let passCode;

  if (
    (event.request.session &&
      event.request.session.length &&
      event.request.session.slice(-1)[0].challengeName == 'SRP_A') ||
    event.request.session.length == 0
  ) {
    passCode = digitGenerator.randomDigits(6).join('');
    await sendChallengeCode(
      event.request.userAttributes.phone_number,
      passCode,
    );
  } else {
    const previousChallenge = event.request.session.slice(-1)[0];
    passCode = previousChallenge.challengeMetadata.match(/CODE-(\d*)/)[1];
  }

  event.response.publicChallengeParameters = {
    phone: event.request.userAttributes.phone_number,
  };
  event.response.privateChallengeParameters = { passCode };
  event.response.challengeMetadata = `CODE-${passCode}`;

  console.log('RETURNED Event: ', JSON.stringify(event, null, 2));
}

exports.handler = async (event) => {
  return createAuthChallenge(event);
};
