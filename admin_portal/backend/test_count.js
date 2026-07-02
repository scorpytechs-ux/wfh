const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const serviceAccount = require('./serviceAccountKey.json');

if (!require('firebase-admin/app').getApps().length) {
    initializeApp({ credential: cert(serviceAccount) });
}
const db = getFirestore();

async function testCount() {
    try {
        const id = 'd7e68625-5c4b-4260-bc22-c71df3d5a09f';
        const snapshot = await db.collection('forms')
            .where('userId', '==', id)
            .where('submittedDate', '>=', '2026-07-01')
            .where('submittedDate', '<', '2026-08-01')
            .count()
            .get();
        console.log("Count:", snapshot.data().count);
    } catch (e) {
        console.log("Error:", e.message);
    }
}
testCount();
