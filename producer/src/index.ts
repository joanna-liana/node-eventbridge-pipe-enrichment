import AWS from 'aws-sdk';

const eventBridge = new AWS.EventBridge({
  endpoint: 'http://localhost:4566',
  region: 'us-east-1'
});

const params: AWS.EventBridge.PutEventsRequest = {
  Entries: [
    {
      Source: 'PRODUCER.source',
      DetailType: 'PRODUCER.detail',
      Detail: JSON.stringify({ message: 'Hello from Producer!', secretId: 42 }),
      EventBusName: 'default'
    }
  ]
};

async function publishEvent() {
  try {
    const result = await eventBridge.putEvents(params).promise();
    console.log('Event published:', result);
  } catch (error) {
    console.error('Error publishing event:', error);
  }
}

publishEvent();
