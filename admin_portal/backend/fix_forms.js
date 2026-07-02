const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

const serviceAccount = require('./serviceAccountKey.json');
if (!require('firebase-admin/app').getApps().length) {
    initializeApp({ credential: cert(serviceAccount) });
}
const db = getFirestore();

async function fixForms() {
    const userId = "d7e68625-5c4b-4260-bc22-c71df3d5a09f";
    const snapshot = await db.collection('forms').where('userId', '==', userId).get();
    
    let batch = db.batch();
    let count = 0;
    
    for (const doc of snapshot.docs) {
        if (!doc.data().id) {
            batch.update(doc.ref, { id: doc.id });
            count++;
            
            if (count === 500) {
                await batch.commit();
                console.log(`Updated ${count} forms...`);
                batch = db.batch();
                count = 0;
            }
        }
    }
    
    if (count > 0) {
        await batch.commit();
    }
    
    console.log("Successfully fixed all forms by adding the missing 'id' field!");
    process.exit(0);
}

fixForms();
