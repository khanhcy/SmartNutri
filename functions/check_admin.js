const admin = require("firebase-admin");

admin.initializeApp({
  credential: admin.credential.applicationDefault()
});

admin.auth().listUsers(10).then((listUsersResult) => {
  listUsersResult.users.forEach((userRecord) => {
    console.log("user", userRecord.toJSON());
  });
  process.exit(0);
}).catch((error) => {
  console.log("Error listing users:", error);
  process.exit(1);
});
