const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

const serviceAccount = require('./serviceAccountKey.json');
if (!require('firebase-admin/app').getApps().length) {
    initializeApp({ credential: cert(serviceAccount) });
}
const db = getFirestore();

async function doubleCheck() {
    const userDoc = await db.collection('users').doc('d7e68625-5c4b-4260-bc22-c71df3d5a09f').get();
    console.log("USER:", userDoc.data());

    const forms = await db.collection('forms').where('userId', '==', 'd7e68625-5c4b-4260-bc22-c71df3d5a09f').limit(1).get();
    if (!forms.empty) {
        console.log("FORM:", forms.docs[0].data());
    } else {
        console.log("No forms found for that ID!");
    }
    process.exit(0);
}
doubleCheck();
