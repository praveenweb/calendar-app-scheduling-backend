## Calendar App Scheduling Backend with Hasura

This is a sample app schema with Node.js functions to handle custom logic and schedule event webhooks for a Hasura backend.

### Deploy Hasura

1. Click on the following button to deploy GraphQL engine on Hasura Cloud including Postgres add-on or using an existing Postgres database:

    [![Deploy to Hasura Cloud](https://graphql-engine-cdn.hasura.io/img/deploy_to_hasura.png)](https://cloud.hasura.io/)

2. Open the Hasura console

   Click on the button "Launch console" to open the Hasura console.

### Apply migrations

1. Head over to hasura folder in this repo.

```bash
cd hasura
```

```bash
hasura migrate apply --endpoint <hasura-cloud-app-url>
hasura metadata apply --endpoint <hasura-cloud-app-url>
```

Once you do this, the schema will be created on Postgres and the metadata will be applied.

Open Hasura Console to verify the same.

### Custom Business Logic

There's a simple Node.js app inside functions folder which gives prototype for setting up custom logic for this app along with a basic example of scheduling.
