const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

const serviceAccount = require('./serviceAccountKey.json');
if (!require('firebase-admin/app').getApps().length) {
    initializeApp({ credential: cert(serviceAccount) });
}
const db = getFirestore();

async function check() {
    const userId = "d7e68625-5c4b-4260-bc22-c71df3d5a09f";
    const snapshot = await db.collection('forms').where('userId', '==', userId).get();
    console.log(`User ${userId} has ${snapshot.size} forms by direct where clause.`);
    
    // What if the userId in forms is different?
    const allForms = await db.collection('forms').limit(5).get();
    allForms.forEach(doc => {
        console.log(`Form ${doc.id} userId:`, doc.data().userId);
    });
    
    process.exit(0);
}

check();
