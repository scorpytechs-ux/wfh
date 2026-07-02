const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const serviceAccount = require('./serviceAccountKey.json');
if (!require('firebase-admin/app').getApps().length) {
    initializeApp({ credential: cert(serviceAccount) });
}
const db = getFirestore();

async function updateStats() {
    const userId = 'd7e68625-5c4b-4260-bc22-c71df3d5a09f';
    const snapshot = await db.collection('forms').where('userId', '==', userId).get();
    
    let activeCount = 0;
    let archivedCount = 0;
    let totalScore = 0;
    
    snapshot.forEach(doc => {
        const d = doc.data();
        if (d.status === 'archived') {
            archivedCount++;
        } else {
            activeCount++;
            totalScore += (typeof d.score === 'number' ? d.score : 100);
        }
    });
    
    const overallScore = activeCount > 0 ? (totalScore / activeCount).toFixed(2) : 0;
    
    await db.collection('users').doc(userId).update({
        stats: {
            activeCount,
            archivedCount,
            overallScore: parseFloat(overallScore)
        }
    });
    
    console.log('User stats updated:', { activeCount, archivedCount, overallScore });
    process.exit(0);
}

updateStats();
