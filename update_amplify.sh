#!/bin/bash
set -e
IFS='|'

# Read arguments passed to a script:
while getopts a:s:i:e:f:fs flag
do
    case "${flag}" in
        a) AWS_ACCESS_KEY_ID=${OPTARG};;
        s) AWS_SECRET_ACCESS_KEY=${OPTARG};;
        i) APP_ID=${OPTARG};;
        e) AMPLIFY_ENV=${OPTARG};;
        f) AMPLIFY_FACEBOOK_CLIENT_ID=${OPTARG};;
        fs) AMPLIFY_FACEBOOK_CLIENT_SECRET=${OPTARG};;
    esac
done

# For debug purposes
#echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID";
#echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY";
#echo "APP_ID: $APP_ID";
#echo "AMPLIFY_ENV: $AMPLIFY_ENV";
#echo "AMPLIFY_FACEBOOK_CLIENT_ID: $AMPLIFY_FACEBOOK_CLIENT_ID"
#echo "AMPLIFY_FACEBOOK_CLIENT_SECRET: $AMPLIFY_FACEBOOK_CLIENT_SECRET"


AWSCLOUDFORMATIONCONFIG="{\
\"configLevel\":\"project\",\
\"useProfile\":false,\
\"profileName\":\"default\",\
\"accessKeyId\":\"$AWS_ACCESS_KEY_ID\",\
\"secretAccessKey\":\"$AWS_SECRET_ACCESS_KEY\",\
\"region\":\"us-east-1\"\
}"
AMPLIFY="{\
\"projectName\":\"animeal\",\
\"envName\":\"$AMPLIFY_ENV\",\
\"defaultEditor\":\"Xcode\"\
\"appId\":\"$APP_ID\",\
}"
FRONTEND="{\
\"frontend\":\"ios\",\
}"
PROVIDERS="{\
\"awscloudformation\":$AWSCLOUDFORMATIONCONFIG\
}"
AUTHCONFIG="{\
\"facebookAppIdUserPool\":\"${AMPLIFY_FACEBOOK_CLIENT_ID}\",\
\"facebookAppSecretUserPool\":\"${AMPLIFY_FACEBOOK_CLIENT_SECRET}\",\
}"
CATEGORIES="{\
\"auth\":$AUTHCONFIG\
}"

# For debug purposes
# echo $AMPLIFY
# echo $FRONTEND
# echo $PROVIDERS
# echo $AWSCLOUDFORMATIONCONFIG


amplify pull \
--amplify $AMPLIFY \
--frontend $FRONTEND \
--providers $PROVIDERS \
--categories $CATEGORIES \
--yes

# Sometimes it's required to run codegen explicitly
amplify codegen models
