require('dotenv').config();
const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

let serviceAccount;
try {
  serviceAccount = require('./serviceAccountKey.json');
} catch (err) {
  console.error("Could not load serviceAccountKey.json:", err.message);
  process.exit(1);
}

if (!require('firebase-admin/app').getApps().length) {
    initializeApp({
      credential: cert(serviceAccount)
    });
}
const db = getFirestore();

const groundTruth = {
    "title": "Miss.",
    "firstName": "Ashlynn",
    "lastName": "Lipscomb",
    "initial": "Parish",
    "email": "ashlynnlipscomb@gmail.com",
    "fatherName": "Zole",
    "dob": "2006-08-27",
    "gender": "Female",
    "profession": "Shop Manager",
    "mailingStreet": "777 Elmwood Dr",
    "mailingCity": "Atlanta",
    "mailingPostal": "30302",
    "mailingCountry": "USA",
    "serviceProvider": "Shaw Communications",
    "fileNo": "76180379",
    "referenceNo": "@j_>B...[S|<76]",
    "simNo": "49019504522720900000",
    "typeOfNetwork": "Shaw Communications",
    "cellModelNo": "799228773",
    "imsi1": "828120726858670",
    "imsi2": "2410317799J...",
    "typeOfPlan": "Healthcare Plans",
    "creditCardType": "Dunkin1",
    "contractValue": "USD150",
    "dateOfIssue": "2004-12-08",
    "dateOfRenewal": "2007-12-08",
    "installment": "4.596",
    "amountInWords": "Four Point Five Ninety Six",
    "remarks": "Not Applicable"
};

async function seedForms(userId) {
    console.log(`Starting to seed 1500 forms for user ${userId}...`);
    
    // First, let's delete any existing forms for this user so we don't have duplicates
    const snapshot = await db.collection('forms').where('userId', '==', userId).get();
    if (!snapshot.empty) {
        console.log(`Deleting ${snapshot.size} existing forms...`);
        let delBatch = db.batch();
        let delCount = 0;
        for (const doc of snapshot.docs) {
            delBatch.delete(doc.ref);
            delCount++;
            if (delCount === 500) {
                await delBatch.commit();
                delBatch = db.batch();
                delCount = 0;
            }
        }
        if (delCount > 0) {
            await delBatch.commit();
        }
        console.log('Existing forms deleted.');
    }

    const todayStr = new Date().toISOString().substring(0, 10);
    let batch = db.batch();
    let count = 0;
    
    for (let i = 1; i <= 1500; i++) {
        const formRef = db.collection('forms').doc();
        batch.set(formRef, {
            ...groundTruth,
            serialNo: i.toString(),
            formNumber: i,
            userId: userId,
            status: 'pending',
            submittedDate: todayStr,
            createdAt: new Date().toISOString()
        });
        
        count++;
        
        if (count === 500) {
            await batch.commit();
            console.log(`Committed ${i} forms...`);
            batch = db.batch();
            count = 0;
        }
    }
    
    if (count > 0) {
        await batch.commit();
    }
    
    // Set user's target to 1500
    await db.collection('users').doc(userId).update({
        monthlyTarget: 1500
    });
    
    console.log(`Successfully seeded 1500 perfect forms for user ${userId}!`);
    process.exit(0);
}

const userId = process.argv[2];
if (!userId) {
    console.error("Please provide a userId as the first argument.");
    process.exit(1);
}

seedForms(userId);
