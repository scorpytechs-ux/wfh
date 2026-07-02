const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

const serviceAccount = require('./serviceAccountKey.json');
if (!require('firebase-admin/app').getApps().length) {
    initializeApp({ credential: cert(serviceAccount) });
}
const db = getFirestore();

async function checkUser() {
    const username = "shubh123";
    const snapshot = await db.collection('users').where('username', '==', username).get();
    
    if (snapshot.empty) {
        console.log("No user found.");
    } else {
        snapshot.forEach(doc => {
            console.log(`Doc ID: ${doc.id}`);
            console.log("Data:", doc.data());
        });
    }
    
    process.exit(0);
}

checkUser();
