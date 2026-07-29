import * as admin from "firebase-admin";

/**
 * Single Firebase Admin SDK initialization point.
 * Import `db`, `auth`, `storage` from here everywhere else in the backend —
 * never call admin.initializeApp() more than once.
 */
if (admin.apps.length === 0) {
  admin.initializeApp();
}

export const db = admin.firestore();
export const auth = admin.auth();
export const storage = admin.storage();
export const FieldValue = admin.firestore.FieldValue;
export const Timestamp = admin.firestore.Timestamp;

export default admin;
