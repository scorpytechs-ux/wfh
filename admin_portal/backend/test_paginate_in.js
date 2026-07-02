const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const serviceAccount = require('./serviceAccountKey.json');
if (!require('firebase-admin/app').getApps().length) {
    initializeApp({ credential: cert(serviceAccount) });
}
const db = getFirestore();

async function testPaginateIn() {
    console.time('fetch_page');
    try {
        const snapshot = await db.collection('forms')
          .where('userId', '==', 'd7e68625-5c4b-4260-bc22-c71df3d5a09f')
          .where('status', 'in', ['pending', 'evaluated', 'sent'])
          .limit(50)
          .offset(0)
          .get();
        console.timeEnd('fetch_page');
        console.log('Docs fetched:', snapshot.size);
    } catch (e) {
        console.error(e.message);
    }
    process.exit(0);
}

testPaginateIn();
