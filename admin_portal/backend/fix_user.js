const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

const serviceAccount = require('./serviceAccountKey.json');
if (!require('firebase-admin/app').getApps().length) {
    initializeApp({ credential: cert(serviceAccount) });
}
const db = getFirestore();

async function fixUser() {
    const id = "d7e68625-5c4b-4260-bc22-c71df3d5a09f";
    await db.collection('users').doc(id).update({ id: id });
    console.log(`Added 'id' field to user document ${id}`);
    
    // Also, if any forms were saved with 'shubh123', update them to the UUID
    const oldForms = await db.collection('forms').where('userId', '==', 'shubh123').get();
    if (!oldForms.empty) {
        let batch = db.batch();
        oldForms.forEach(doc => {
            batch.update(doc.ref, { userId: id });
        });
        await batch.commit();
        console.log(`Updated ${oldForms.size} forms from 'shubh123' to UUID`);
    }
    
    process.exit(0);
}

fixUser();
