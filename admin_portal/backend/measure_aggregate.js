const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore, AggregateField } = require('firebase-admin/firestore');
const serviceAccount = require('./serviceAccountKey.json');
if (!require('firebase-admin/app').getApps().length) {
    initializeApp({ credential: cert(serviceAccount) });
}
const db = getFirestore();

async function testAggregate() {
    console.time('fetch_aggregate');
    const aggregate = await db.collection('forms')
      .where('userId', '==', 'd7e68625-5c4b-4260-bc22-c71df3d5a09f')
      .where('status', '!=', 'archived')
      .aggregate({
          totalScore: AggregateField.sum('score'),
          count: AggregateField.count()
      }).get();
      
    const data = aggregate.data();
    console.timeEnd('fetch_aggregate');
    console.log('Stats:', data);
    process.exit(0);
}

testAggregate();
