/* Amplify Params - DO NOT EDIT
	ENV
	REGION
Amplify Params - DO NOT EDIT */
const AWS = require('aws-sdk');
const { parse } = require('node-html-parser');
const { split } = require('sentence-splitter');
AWS.config.update({ region: process.env.REGION || 'eu-central-1' });
const translate = new AWS.Translate({});
const TRANSLATE_LIMIT_TEXT_SIZE = 5000;

const containsHTML = (str) => /<[a-z][\s\S]*>/i.test(str);

async function translateByBatches(value, params) {
  if (value) {
    let batch = '';
    let batches = [];
    if (Buffer.byteLength(value, 'utf-8') < TRANSLATE_LIMIT_TEXT_SIZE) {
      batches.push(value);
    } else {
      batches = split(value, {
        SeparatorParser: {
          separatorCharacters: ['.', '!', '?'],
        },
      }).reduce((acc, data, index, array) => {
        if (
          Buffer.byteLength(batch + data.raw, 'utf-8') >=
          TRANSLATE_LIMIT_TEXT_SIZE
        ) {
          acc.push(batch);
          batch = '';
        }
        batch += data.raw;
        if (index === array.length - 1) {
          acc.push(batch);
        }

        return acc;
      }, []);
    }
    value = (
      await Promise.all(
        batches.map((batch) =>
          asyncTranslate(params.langFrom || 'auto', params.langTo, batch),
        ),
      )
    ).join();
  }
  return value;
}

async function replacer(text, params) {
  if (text.childNodes.length) {
    for (const elem of text.childNodes) {
      await replacer(elem, params);
    }
  } else {
    let value = text.rawText;
    value = await translateByBatches(value, params);
    text.rawText = value;
  }
}

async function parseAndTranslate(body, params) {
  if (containsHTML(body)) {
    let root = parse(body);
    for (const elem of root.childNodes) {
      await replacer(elem, params);
    }
    return root.toString();
  } else {
    return translateByBatches(body, params);
  }
}

async function asyncTranslate(langFrom, langTo, text) {
  const params = {
    SourceLanguageCode: langFrom,
    TargetLanguageCode: langTo,
    Text: text,
  };

  const translation = await translate.translateText(params).promise();
  return translation.TranslatedText;
}

exports.handler = async (event, context, callback) => {
  const { text, from, to } = event.arguments;

  try {
    const result = await parseAndTranslate(text, {
      langFrom: from,
      langTo: to,
    });

    callback(null, result);
  } catch (err) {
    callback(err);
  }
};
