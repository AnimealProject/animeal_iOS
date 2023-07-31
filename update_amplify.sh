#!/bin/bash
set -e
IFS='|'

# Read arguments passed to a script:
while getopts a:s:i:e:t:r:h flag
do
    case "${flag}" in
        a)
	       # echo "Processing option 'a' with '${OPTARG}' argument"
		   AWS_ACCESS_KEY_ID=${OPTARG}
		   ;;
        s)
	       # echo "Processing option 's' with '${OPTARG}' argument"
		   AWS_SECRET_ACCESS_KEY=${OPTARG}
           ;;
        i)
	        # echo "Processing option 'i' with '${OPTARG}' argument"
			APP_ID=${OPTARG}
			;;
        e)
	        # echo "Processing option 'e' with '${OPTARG}' argument"
			AMPLIFY_ENV=${OPTARG}
			;;
        t)
	        # echo "Processing option 't' with '${OPTARG}' argument"
			FACEBOOK_CLIENT_ID=${OPTARG}
			;;
        r)
			# echo "Processing option 'r' with '${OPTARG}' argument"
			FACEBOOK_CLIENT_SECRET=${OPTARG}
			;;
		?|h)
      		echo "Usage: $(basename $0) [a arg] [s arg] [i arg] [e arg] [t arg] [r arg]"
      		exit 1
      		;;
    esac
done

# For debug purposes
# echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID";
# echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY";
# echo "APP_ID: $APP_ID";
# echo "AMPLIFY_ENV: $AMPLIFY_ENV";
# echo "FACEBOOK_CLIENT_ID: $FACEBOOK_CLIENT_ID";
# echo "FACEBOOK_CLIENT_SECRET: $FACEBOOK_CLIENT_SECRET";


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
\"facebookAppIdUserPool\":\"${FACEBOOK_CLIENT_ID}\",\
\"facebookAppSecretUserPool\":\"${FACEBOOK_CLIENT_SECRET}\"\
}"
CATEGORIES="{\
\"auth\":$AUTHCONFIG\
}"

# For debug purposes
  echo $AMPLIFY
  echo $FRONTEND
  echo $PROVIDERS
  echo $AWSCLOUDFORMATIONCONFIG
  echo $CATEGORIES

# Set up the amplify generated folder if not done already
source Tools/check_amplify_generated_folders.sh

amplify pull \
--amplify $AMPLIFY \
--frontend $FRONTEND \
--providers $PROVIDERS \
--categories $CATEGORIES \
--yes

# Sometimes it's required for CI run codegen explicitly
amplify codegen models
