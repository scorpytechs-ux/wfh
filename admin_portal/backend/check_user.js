const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const serviceAccount = require('C:/Users/Lenovo/Downloads/installment-system-5d42d-firebase-adminsdk-fbsvc-d163407b6b.json');

initializeApp({
  credential: cert(serviceAccount)
});

const db = getFirestore();

async function checkUser() {
    const snapshot = await db.collection('users').get();
    snapshot.forEach(doc => {
        const data = doc.data();
        if (data.role === 'candidate') {
            console.log(doc.id, data.username, "Monthly:", data.monthlyTarget, "Daily:", data.dailyTarget);
        }
    });
}

checkUser();
