const digitGenerator = require('crypto-secure-random-digit');
const AWS = require('aws-sdk');
const sns = new AWS.SNS();

const TEST_ACCOUNTS = {
  '+995555666777': '353535',
  '+995444555666': '454545',
  '+995324555328': '757575',
  '+995987987987': '272727',
  '+995111222333': '999999'
}

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

    // TEST ACCOUNT
    if (
      Object.keys(TEST_ACCOUNTS).includes(event.request.userAttributes.phone_number)
    ) {
      passCode = TEST_ACCOUNTS[event.request.userAttributes.phone_number];
    }

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
