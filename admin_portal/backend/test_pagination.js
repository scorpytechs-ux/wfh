const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const serviceAccount = require('./serviceAccountKey.json');
if (!require('firebase-admin/app').getApps().length) {
    initializeApp({ credential: cert(serviceAccount) });
}
const db = getFirestore();

async function testIndex() {
    try {
        let activeDocs = [];
        let query = db.collection('forms')
          .where('userId', '==', 'd7e68625-5c4b-4260-bc22-c71df3d5a09f')
          .limit(100);

        while (true) {
            const snapshot = await query.get();
            const docs = snapshot.docs;
            console.log('Fetched:', docs.length);
            
            if (docs.length === 0) break;

            for (let doc of docs) {
                const status = doc.data().status || 'pending';
                if (status !== 'archived') activeDocs.push(doc);
            }

            if (docs.length < 100) break;
            
            query = db.collection('forms')
                .where('userId', '==', 'd7e68625-5c4b-4260-bc22-c71df3d5a09f')
                .startAfter(docs[docs.length - 1])
                .limit(100);
        }
        console.log('Total Active Docs:', activeDocs.length);
    } catch (e) {
        console.error("Error:", e.message);
    }
    process.exit(0);
}

testIndex();
