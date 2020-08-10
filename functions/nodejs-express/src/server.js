const express = require("express");
const bodyParser = require("body-parser");
const fetch = require("node-fetch")
const moment = require("moment");

const app = express();

const PORT = process.env.PORT || 3000;

app.use(bodyParser.json());

const HASURA_OPERATION = `
mutation ($object: event_insert_input!) {
  insert_event_one(object: $object) {
    id
  }
}
`;

// execute the parent operation in Hasura
const execute = async (query, variables, headers) => {
  const fetchResponse = await fetch(
    process.env.HASURA_GRAPHQL_ENDPOINT,
    {
      method: 'POST',
      body: JSON.stringify({
        query: HASURA_OPERATION,
        variables
      }),
      headers: {
        'x-hasura-admin-secret': process.env.HASURA_GRAPHQL_ADMIN_SECRET,
        ...headers
      }
    }
  );
  const data = await fetchResponse.json();
  console.log('DEBUG: ', data);
  return data;
};
  
// Request Handler
app.post('/createEvent', async (req, res) => {

  // get request input
  const { object } = req.body.input;
  const { session_variables }  = req.body;

  // run some business logic
  // this is where the validation logic should be placed

  /*
  // check for availability of attendee ids
  const attendees_data = object.attendees.map((attendee, index) => {
    return { user_id: attendee.id };
  });

  // fetch all events of attendees
  const query = `query ($attendees: [Int!]!) {
    event_attendee(where:{user_id: {_in: $attendees}}) {
      id
    }
  }`;
  */

  const finalObject = { object: {
    ...object, attendees: { data: [...attendees_data] }
  }};

  const headers = { ...session_variables };

  // execute the Hasura operation
  const { data, errors } = await execute(HASURA_OPERATION, finalObject, headers);

  // if Hasura operation errors, then throw error
  if (errors) {
    return res.status(400).json(errors[0])
  }
  // insert successful

  // check if recurring event
  const isRecurring = object.isRecurring;
  const recurrencePattern = object.recurrencePattern;

  // schedule an one-off event
  const schedule_event_obj = {
    "type" : "create_scheduled_event",
    "args" : {
        "webhook": process.env.SCHEDULE_WEBHOOK_URL,
        "schedule_at": moment.utc(object.start_date_time_utc).subtract('10','minutes'),
        "payload": {
            attendees_data
        }
    }
  };
  //
  const scheduleResponse = await fetch(
    process.env.HASURA_GRAPHQL_METADATA_ENDPOINT,
    {
      method: 'POST',
      body: JSON.stringify(schedule_event_obj),
      headers: {
        'x-hasura-admin-secret': process.env.HASURA_GRAPHQL_ADMIN_SECRET,
      }
    }
  );
  const scheduleData = await scheduleResponse.json();
  console.log('DEBUG: ', scheduleData);

  // success
  return res.json({
    ...data.insert_event_one
  })

});

// execute the event
app.post('/scheduledEvent', async (req, res) => {
  // logic to check if event is valid before executing further

  // fetch the event details and check the status column

  // if cancelled, don't proceed further

  // if valid, send an email
});

app.post('/hello', async (req, res) => {
  return res.json({
    hello: "world"
  });
});

app.listen(PORT);
