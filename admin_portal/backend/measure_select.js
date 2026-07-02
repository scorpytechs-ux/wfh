const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const serviceAccount = require('./serviceAccountKey.json');
if (!require('firebase-admin/app').getApps().length) {
    initializeApp({ credential: cert(serviceAccount) });
}
const db = getFirestore();

async function testSelect() {
    console.time('fetch_select');
    const snapshot = await db.collection('forms').where('userId', '==', 'd7e68625-5c4b-4260-bc22-c71df3d5a09f').select('score', 'status').get();
    console.timeEnd('fetch_select');
    console.log('Docs fetched:', snapshot.size);
    process.exit(0);
}

testSelect();
