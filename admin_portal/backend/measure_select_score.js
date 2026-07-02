const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const serviceAccount = require('./serviceAccountKey.json');
if (!require('firebase-admin/app').getApps().length) {
    initializeApp({ credential: cert(serviceAccount) });
}
const db = getFirestore();

async function testSelectScore() {
    console.time('fetch');
    const snapshot = await db.collection('forms').where('userId', '==', 'd7e68625-5c4b-4260-bc22-c71df3d5a09f').select('status', 'score').get();
    
    let total = 0;
    let count = 0;
    snapshot.forEach(doc => {
        const d = doc.data();
        if (d.status !== 'archived') {
            count++;
            total += (typeof d.score === 'number' ? d.score : 100);
        }
    });
    console.timeEnd('fetch');
    console.log(`Average: ${total / count}, Count: ${count}`);
    process.exit(0);
}

testSelectScore();
