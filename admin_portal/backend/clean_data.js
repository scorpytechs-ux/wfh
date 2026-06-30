const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
require('dotenv').config();

let serviceAccount;
if (process.env.FIREBASE_SERVICE_ACCOUNT) {
  serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
} else {
  serviceAccount = require('./serviceAccountKey.json');
}

initializeApp({
  credential: cert(serviceAccount)
});

const db = getFirestore();

async function cleanData() {
  console.log("Starting data cleanup...");
  
  const usersSnapshot = await db.collection('users').where('role', '==', 'candidate').get();
  console.log(`Found ${usersSnapshot.size} candidates to delete.`);
  for (const doc of usersSnapshot.docs) {
    await doc.ref.delete();
  }
  
  const formsSnapshot = await db.collection('forms').get();
  console.log(`Found ${formsSnapshot.size} forms to delete.`);
  for (const doc of formsSnapshot.docs) {
    await doc.ref.delete();
  }

  console.log("Data cleaned successfully.");
}

cleanData().catch(console.error).finally(() => process.exit());
