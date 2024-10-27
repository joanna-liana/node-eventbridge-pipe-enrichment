import AWS from 'aws-sdk';

const sqs = new AWS.SQS({
  endpoint: 'http://localhost:4566',
  region: 'us-east-1'
});
const queueUrl = 'http://localhost:4566/000000000000/my-queue';

async function receiveMessages() {
  const params: AWS.SQS.ReceiveMessageRequest = {
    QueueUrl: queueUrl,
    MaxNumberOfMessages: 10,
    WaitTimeSeconds: 5
  };

  try {
    const data = await sqs.receiveMessage(params).promise();
    if (data.Messages) {
      data.Messages.forEach(message => {
        console.log('Received message:', message.Body);
      });
    } else {
      console.log('No messages to receive');
    }
  } catch (error) {
    console.error('Error receiving messages:', error);
  }
}

setInterval(receiveMessages, 10000);
