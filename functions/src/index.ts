import * as admin from "firebase-admin";
import {onRequest} from "firebase-functions/v2/https";

admin.initializeApp();

export const health = onRequest((request, response) => {
  response.status(200).json({
    service: "smartnutri-functions",
    method: request.method,
    ok: true,
    timestamp: Date.now(),
  });
});
