const functions = require('firebase-functions')
const admin = require('firebase-admin')
admin.initializeApp()

exports.sendNotification = functions.firestore
  .document('Messages/{idConv}')
  .onUpdate((change, context) => {
    console.log('----------------start function--------------------')
    const doc = change.after.data()
    var keys = Object.keys(doc);
    keys.sort((a,b) => doc[b].sortOnMe - doc[a].sortOnMe);
    var lesMessages = keys.map(key => doc[key]);
    //const lesMessages = new Map([...doc.entries()].sort((a, b) => b[0] - a[0]));
    const leMessage = lesMessages[lesMessages.length -1];
    const idConv = change.after.id;
    const idEnvoyeur = leMessage.envoyeur
    const idDestinataire = idConv.replace(idEnvoyeur,"")
    const corps = leMessage.corps
    console.log(idConv)
    console.log(idEnvoyeur)
    console.log(idDestinataire)
    console.log(corps)

    admin
      .firestore()
      .collection('Utilisateurs')
      .doc(idEnvoyeur)
      .get()
      .then(envoyeur => {
          const payload = {
            notification: {
              title: `Nouveau message de ${envoyeur.data().pseudo}`,
              body: corps,
              badge: '1',
              sound: 'default',
              collapseKey:idEnvoyeur,
              tag:idEnvoyeur
            }
          }
          admin
            .firestore()
            .collection('Utilisateurs')
            .doc(idDestinataire)
            .get()
            .then(destinataireNotif => {
                console.log(`Destinataires trouvés: ${destinataireNotif.data().pseudo}`)
                if (destinataireNotif.data().jeton && (destinataireNotif.data().co == null || destinataireNotif.data().co!=idConv)) {
                    console.log(destinataireNotif.data().jeton)
                    admin.firestore().collection('ListeMessages').doc(idConv).update({
                        "notif":idDestinataire
                    })
                    admin.messaging().sendToDevice(destinataireNotif.data().jeton, payload)
                        .then(response => {
                          console.log('Message envoyé avec succès:', response, 'à: ',destinataireNotif.data().pseudo)
                        })
                        .catch(error => {
                          console.log('Error sending message:', error)
                        })
                }else {
                    console.log('jeton destinataire introuvable ou pas visible')
                }

            }).catch(error => {
                console.log('Erreur destinataire:', error)
             });
    }).catch(error => {
        console.log('Erreur envoyeur:', error)
   });


    /*// Get push token user to (receive)
    admin
      .firestore()
      .collection('Utilisateurs')
      .get()
      .then(querySnapshot => {
        querySnapshot.forEach(userTo => {
          console.log(`Destinataires trouvés: ${userTo.data().pseudo}`)
          if (userTo.data().pushToken && !userTo.data().co) {
            // Get info user encore (sent)
            admin
              .firestore()
              .collection('Utilisateurs')
              .where('id', '==', idEnvoyeur)
              .get()
              .then(querySnapshot2 => {
                querySnapshot2.forEach(userFrom => {
                  console.log(`Utilisateur envoyeur: ${userFrom.data().nickname}`)
                  const payload = {
                    notification: {
                      title: `Message de "${userFrom.data().nickname}"`,
                      body: contentMessage,
                      badge: '1',
                      sound: 'default'
                    }
                  }
                  // Let push to the target device
                  admin
                    .messaging()
                    .sendToDevice(userTo.data().pushToken, payload)
                    .then(response => {
                      console.log('Message envoyé avec succès:', response)
                    })
                    .catch(error => {
                      console.log('Error sending message:', error)
                    })
                })
              })
          } else {
            console.log('Can not find pushToken target user')
          }
        })
      })*/
    return null
  })