const functions = require("firebase-functions");
const express = require('express');
var path = require('path');
// const fs = require('fs');

const admin = require('firebase-admin');

// Load service account from env (public-repo safe) or local file for dev
function getServiceAccount() {
  if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
    return JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
  }
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    return require(process.env.GOOGLE_APPLICATION_CREDENTIALS);
  }
  try {
    return require("./b1d668fbd6.json");
  } catch (e) {
    throw new Error(
      "Firebase credentials required. Set FIREBASE_SERVICE_ACCOUNT_JSON or GOOGLE_APPLICATION_CREDENTIALS, " +
      "or add b1d668fbd6.json (see b1d668fbd6.json.example)"
    );
  }
}
var serviceAccount = getServiceAccount();
var storageBucket = process.env.FIREBASE_STORAGE_BUCKET || "YOUR_PROJECT_ID.appspot.com";

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: storageBucket
});

const db = admin.firestore();
const auth = admin.auth();

const cinemawala = express();

const multer = require('multer');

var storage =   multer.diskStorage({  
  destination: (req, file, callback) => {  
    console.log(file);
    callback(null, './uploads');  
  },  
  filename: (req, file, callback) => {  
    console.log(file);
    callback(null, "image.png");  
  }  
});  

const upload = multer({ storage: storage }).single('myfile');

cinemawala.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  res.header(
    "Access-Control-Allow-Headers",
    "Origin, X-Requested-With, Content-Type, Accept"
  );
  next();
});

cinemawala.post("/uploadImage", async (req, res) => {
  upload(req, res, function (err) {
    if (err) {
      console.log(err);
      return res.end("Error uploading file.");
    }
    res.end("File is uploaded successfully!");
  });

});

async function validateUsername(username) {
  try {
    var u = await db.collection("data").doc("users").get();
    var us = u.data()["usernames"];
    var usernames = Object.keys(us).map(function (key) {
      return us[key][0];
    });
    return !usernames.includes(username);
  } catch (e) {
    console.log(e);
    return false;
  }
}

cinemawala.post("/validateUsername", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var valid = false;

  try {
    if (await validateUsername(body.username)) {
      status = 'success';
      msg = 'User Id is valid';
      valid = true;
    } else {
      status = 'failure';
      msg = 'User Id is already used.';
      valid = false;
    }
  } catch (e) {
    status = 'failure';
    msg = 'User Id is already used.';
    valid = false;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
    'valid': valid
  });
});

cinemawala.post("/getAllUsernames", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var usernames = [];

  try {
    var u = await db.collection("data").doc("users").get();
    var us = u.data()["usernames"];
    var usernames = [];
    for (const [key, value] of Object.entries(us)) {
      usernames.push({ "username": value[0], "name": value[1], "id": key })
    }
    status = 'success';
    msg = "Got Usernames successfully";
  } catch (e) {
    status = 'failure';
    msg = "Usernames get successfully " + e;
    console.log(e);
  }

  res.status(200).send({
    'msg': msg,
    'status': status,
    'usernames': usernames
  });
});

cinemawala.post("/getUser", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var user = {};

  try {
    await db.runTransaction(async (t) => {
      const usr = await t.get(db.collection('users').doc(body['id']));
      if (usr.exists) {
        status = 'success';
        user = usr.data();
        msg = 'Got User successfully.';
      } else {
        status = 'failure';
        msg = 'User details does not exist. Please Register'
        user = {};
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
    user = {};
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
    'user': user
  });
});

cinemawala.post("/addUser", async (req, res) => {
  var body = req.body;
  var msg = 'Something went wrong.';
  var status = 'failure';

  try {
    await db.runTransaction(async (t) => {
      const u = await t.get(db.collection("data").doc("users"));
      var usernames = Object.keys(u).map(function (key) {
        return u[key][0];
      });
      if (!usernames.includes(body.username)) {
        await auth.createUser({
          email: body.email,
          emailVerified: false,
          phoneNumber: body.mobile,
          password: body.password,
          displayName: body.name,
          uid: body.id,
          disabled: false,
        }).then(async (userRecord) => {

          delete body['password']
          t.set(db.collection('users').doc(body['id']), body);
          usbo = {};
          usbo["usernames." + body['id']] = [body.username, body.name];

          t.update(db.collection('data').doc('users'), usbo);

          status = "success";
          msg = "User added succesfully";
        })
          .catch((error) => {
            status = 'failure';

            console.log(error);

            if (error.code === "auth/email-already-exists") {
              msg = "Email Id already registered. Please Login.";
            } else if (error.code === "auth/invalid-display-name") {
              msg = "Name contains unallowed characters. Please correct the name.";
            } else if (error.code === "auth/invalid-email") {
              msg = "Invalid Email. Please check and try once again.";
            } else if (error.code === "auth/invalid-password") {
              msg = "Invalid Password. Please check and try once again.";
            } else if (error.code === "auth/invalid-phone-number") {
              msg = "The mobile number you have entered is invalid. Please check and try once again.";
            } else if (error.code === "auth/phone-number-already-exists") {
              msg = "The mobile number you have entered is already in use.";
            } else {
              msg = "Something went wrong. Please try again."
            }
          });
      } else {
        status = "failure";
        msg = "Username already used. Choose different one.";
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/userForgotPassword", async (req, res) => {
  var body = req.body;
  var msg = 'Something went wrong.';
  var status = 'failure';

  try {
    await auth.generatePasswordResetLink(body.email);
  } catch (e) {
    console.log(e);
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

//Personal Calender

cinemawala.post("/addNote", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  try {
    await db.runTransaction(async (t) => {
      const user = await t.get(db.collection('users').doc(body['user_id']));
      if (user.exists) {
        var te = {};
        var note = body.note;
        var new_note = note.notes;
        note['notes'] = admin.firestore.FieldValue.arrayUnion(new_note);
        te["notes." + note.id] = note;
        t.update(db.collection('users').doc(body['user_id']), te);
      } else {
        status = 'failure';
        msg = 'User does not exist.'
      }
    });
    if (msg === '') {
      status = 'success';
      msg = 'Note added successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/removeNote", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  try {
    await db.runTransaction(async (t) => {
      const user = await t.get(db.collection('users').doc(body['user_id']));
      if (user.exists) {
        var te = {};
        var note = body.note;
        var old_note = note.notes;
        note['notes'] = admin.firestore.FieldValue.arrayRemove(old_note);
        te["notes." + note.id] = note;
        t.update(db.collection('users').doc(body['user_id']), te);
      } else {
        status = 'failure';
        msg = 'User does not exist.'
      }
    });
    if (msg === '') {
      status = 'success';
      msg = 'Note added successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

//Project

cinemawala.post("/addProject", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  try {
    await db.runTransaction(async (t) => {
      t.set(db.collection('projects').doc(body.id), body);
      var te = {};
      te["projects." + body['id']] = { id: body.id, role: "Owner", owner: true, accepted: true };
      t.update(db.collection('users').doc(body.owner_id), te);
    });
    if (msg === '') {
      status = 'success';
      msg = 'Project added successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/editProject", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.last_edit_by)) {
          if (project.data()['roles'][body.last_edit_by]['owner']) {
            t.update(db.collection('projects').doc(body['id']), body);
          } else {
            status = 'failure';
            msg = 'You are not permitted to edit project.'
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
      }
    });
    if (msg === '') {
      status = 'success';
      msg = 'Artist edited successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/getProjects", async (req, res) => {
  var body = req.body;
  console.log(1);
  var user_id = body['user_id'];
  // await db.collection('projects').doc('jBVRGq').update();
  const snaps = await db.collection('projects').where('roles_ids', 'array-contains', user_id).get();
  var projects = [];
  snaps.docs.forEach(doc => {
    projects.push(doc.data());
  });
  res.status(200).send({
    'status': 'success',
    'msg': 'Got Projects successfully.',
    'projects': projects
  });
});

cinemawala.post("/getArtistProjects", async (req, res) => {
  var body = req.body;
  console.log(1);
  var user_id = body['user_id'];
  // await db.collection('projects').doc('jBVRGq').update();
  const snaps = await db.collection('projects').where('artist_ids', 'array-contains', user_id).get();
  var projects = [];
  snaps.docs.forEach(doc => {
    projects.push(doc.data());
  });
  res.status(200).send({
    'status': 'success',
    'msg': 'Got Artist Projects successfully.',
    'projects': projects
  });
});

cinemawala.post("/getProject", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var project = {};

  try {
    await db.runTransaction(async (t) => {
      const proj = await t.get(db.collection('projects').doc(body['project_id']));
      if (proj.exists) {
        if (proj.data()['roles_ids'].includes(body.user_id)) {
          status = 'success';
          project = proj.data();
          msg = 'Got Project successfully.';
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          project = {};
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        project = {};
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
    project = {};
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
    'project': project
  });
});

// Artist Project

cinemawala.post("/getArtistProject", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var project = {};

  try {
    await db.runTransaction(async (t) => {
      const proj = await t.get(db.collection('projects').doc(body['project_id']));
      if (proj.exists) {
        var artist_id = "";
        var aIds = proj.data()["artists"];
        var i = Object.keys(aIds).map(function (key) {
          if (aIds[key] == body.user_id) {
            artist_id = key;
          }
          return aIds[key];
        });
        if (artist_id !== "") {

          project['project'] = proj.data();

          await t.get(db.collection('projects').doc(body['project_id']).collection('Artists').doc(artist_id)).then(async (act) => {
            if (act.exists) {
              var actor = act.data();
              project['actor'] = actor;

              var scenes = [];
              var costume_ids = [""];
              var location_ids = [""];
              var scene_ids = [""];

              await t.get(db.collection('projects').doc(body['project_id']).collection('Scenes').where("artists", 'array-contains', artist_id)).then((docs) => {
                docs.docs.forEach(doc => {
                  scenes.push(doc.data());
                  scene_ids.push(doc.data()['id']);
                  location_ids.push(doc.data()['location']);
                  var c = doc.data()['costumes'].find(e => e.id === artist_id);
                  if (c !== undefined)
                    costume_ids = costume_ids.concat(c.costumes);
                });
              }).catch((e) => { console.log(e); scenes = [] });

              project['scenes'] = scenes;

              location_ids = Array.from(new Set(location_ids));
              var locations = [];
              await t.get(db.collection('projects').doc(body['project_id']).collection('Locations').where("id", 'in', location_ids)).then((docs) => {
                docs.docs.forEach(doc => {
                  locations.push(doc.data());
                });
              }).catch((e) => { console.log(e); locations = [] });
              project['locations'] = locations;

              costume_ids = Array.from(new Set(costume_ids));
              var costumes = [];
              await t.get(db.collection('projects').doc(body['project_id']).collection('Costumes').where("id", 'in', costume_ids)).then((docs) => {
                docs.docs.forEach(doc => {
                  costumes.push(doc.data());
                });
              }).catch((e) => { console.log(e); costumes = [] });
              project['costumes'] = costumes;

              var schedules = [];
              await t.get(db.collection('projects').doc(body['project_id']).collection('Schedules').where("scenes", 'array-contains-any', scene_ids)).then((docs) => {
                docs.docs.forEach(doc => {
                  schedules.push(doc.data());
                });
              }).catch((e) => { console.log(e); schedules = [] });
              project['schedules'] = schedules;

              status = 'success';
              msg = 'Got Project successfully.';
            } else {
              status = 'failure';
              msg = 'Artist does not exist.'
              actor = {};
            }
          }).catch((e) => { console.log(e); });

        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          project = {};
        }

      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        project = {};
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
    project = {};
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
    'project': project
  });
});

cinemawala.post("/generateCastCode", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = 'success';
  var code = "";

  var text = "abcdefghijklmnopqrstuvwxyz";
  // text += "!@#$%^&*()";
  text += "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  // text += "`[]\;',./-=";
  text += "0123456789";
  // text += "~{}|:\"<>?";

  var length = text.length - 1;

  try {
    await db.runTransaction(async (t) => {
      const user = await t.get(db.collection('users').doc(body['user_id']));
      if (user.exists) {

        do {
          code = "";
          for (let i = 0; i < 10; i++) {
            var index = Math.ceil(Math.random() * length);
            if (index < 0 || index >= text.length) {
              index = 0
            }
            code += text[index];
          }
        } while (user.data()["codes"][code === undefined]);

        if (code.length > 10) {
          code = code.substring(0, 10);
        }

        msg = "Code generated successfully";

        var codeBody = {};
        codeBody['codes.' + code] = {
          "code": code,
          "created": Date.now(),
          "used": false
        }

        t.update(db.collection('users').doc(body['user_id']), codeBody);

      } else {
        status = 'failure';
        msg = 'User does not exist.'
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }

  res.status(200).send({
    'msg': msg,
    'status': status,
    'code': code
  });
});

cinemawala.post("/validateCastCode", async (req, res) => {
  var body = req.body;
  var msg = 'Valid Code';
  var status = 'success';
  var valid = false;

  try {
    await db.runTransaction(async (t) => {
      const user = await t.get(db.collection('users').doc(body['user_id']));
      if (user.exists) {
        if (user.data()['codes'][body.code] !== undefined) {

          var code = user.data()['codes'][body.code];
          var created = code['created'];
          var now = Date.now();
          var diffTime = Math.abs(now - created);
          diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

          if (diffDays <= 7) {
            if (!code['used']) {
              status = 'success';
              msg = 'Code is valid.'
              valid = true;
            } else {
              status = 'failure';
              msg = 'Code Already Used.'
            }
          } else {
            status = 'failure';
            msg = 'Code Expired.'
          }

        } else {
          status = 'failure';
          msg = 'Invalid Code.'
        }
      } else {
        status = 'failure';
        msg = 'User does not exist.'
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }

  res.status(200).send({
    'msg': msg,
    'status': status,
    'valid': valid
  });
});

cinemawala.post("/assignCast", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.last_edit_by)) {
          if (project.data()['roles'][body.last_edit_by]['permissions']['casting']['edit']) {
            if (!project.data()['artist_ids'].includes(body['user_id'])) {

              t.update(db.collection('projects').doc(body['project_id']).collection('Artists').doc(body['id']), { "by": { "username": body["username"], "user_id": body["user_id"] } });

              var ab = {
                "artist_ids": admin.firestore.FieldValue.arrayUnion(body.user_id)
              }
              ab["artists." + body.id] = body.user_id;
              t.update(db.collection('projects').doc(body['project_id']), ab);

              ab = {};
              ab["acts_in." + body.project_id] = {
                "as": body.id,
                "code": body.code,
                "id": body.project_id
              };
              ab["codes." + body.code + ".used"] = true;
              t.update(db.collection('users').doc(body['user_id']), ab);

            } else {
              status = 'failure';
              msg = 'User already assigned.'
            }
          } else {
            status = 'failure';
            msg = 'You are not permitted to remove cast.'
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
      }
    });
    if (msg === '') {
      status = 'success';
      msg = 'Cast removed successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/removeCast", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.last_edit_by)) {
          if (project.data()['roles'][body.last_edit_by]['permissions']['casting']['edit']) {
            t.update(db.collection('projects').doc(body['project_id']).collection('Artists').doc(body['id']), { "by": { "username": "", "user_id": "" } });

            var ab = {
              "artist_ids": admin.firestore.FieldValue.arrayRemove(body.user_id)
            }
            ab["artists." + body.id] = admin.firestore.FieldValue.delete();
            t.update(db.collection('projects').doc(body['project_id']), ab);

            ab = {};
            ab["acts_in." + body.project_id] = admin.firestore.FieldValue.delete();
            t.update(db.collection('users').doc(body['user_id']), ab);

          } else {
            status = 'failure';
            msg = 'You are not permitted to remove cast.'
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
      }
    });
    if (msg === '') {
      status = 'success';
      msg = 'Cast removed successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

//Artist

cinemawala.post("/addArtist", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.added_by)) {
          if (project.data()['roles'][body.added_by]['permissions']['casting']['add']) {
            t.set(db.collection('projects').doc(body['project_id']).collection('Artists').doc(body['id']), body);
          } else {
            status = 'failure';
            msg = 'You are not permitted to add artists.'
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
      }
    });
    if (msg === '') {
      status = 'success';
      msg = 'Artist added successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/editArtist", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.last_edit_by)) {
          if (project.data()['roles'][body.last_edit_by]['permissions']['casting']['edit']) {
            t.set(db.collection('projects').doc(body['project_id']).collection('Artists').doc(body['id']), body);
          } else {
            status = 'failure';
            msg = 'You are not permitted to edit artists.'
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
      }
    });
    if (msg === '') {
      status = 'success';
      msg = 'Artist edited successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/getArtist", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var actor = {};

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.user_id)) {
          if (project.data()['roles'][body.user_id]['permissions']['casting']['view']) {
            const act = await t.get(db.collection('projects').doc(body['project_id']).collection('Artists').doc(body['id']));
            if (act.exists) {
              status = 'success';
              actor = act.data();
              msg = 'Got Artist successfully.';
            } else {
              status = 'failure';
              msg = 'Artist does not exist.'
              actor = {};
            }
          } else {
            status = 'failure';
            msg = 'You are not permitted to view artists.'
            actor = {};
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          actor = {};
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        actor = {};
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
    actor = {};
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
    'actor': actor
  });
});

cinemawala.post("/getArtists", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var actors = [];

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.user_id)) {
          if (project.data()['roles'][body.user_id]['permissions']['casting']['view']) {
            const acts = await t.get(db.collection('projects').doc(body['project_id']).collection('Artists'));
            acts.docs.forEach(doc => {
              actors.push(doc.data());
            });
            status = 'success';
            msg = 'Got Artists successfully.';
          } else {
            status = 'failure';
            msg = 'You are not permitted to view artists.'
            actors = [];
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.';
          actors = [];
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.';
        actors = [];
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
    actors = [];
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
    'actors': actors
  });
});

//Costumes

cinemawala.post("/addCostume", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.added_by)) {
          if (project.data()['roles'][body.added_by]['permissions']['costumes']['add']) {
            t.set(db.collection('projects').doc(body['project_id']).collection('Costumes').doc(body['id']), body);
          } else {
            status = 'failure';
            msg = 'You are not permitted to add costumes.'
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
      }
    });
    if (msg === '') {
      status = 'success';
      msg = 'Costume added successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/editCostume", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.last_edit_by)) {
          if (project.data()['roles'][body.last_edit_by]['permissions']['costumes']['edit']) {
            t.set(db.collection('projects').doc(body['project_id']).collection('Costumes').doc(body['id']), body);
          } else {
            status = 'failure';
            msg = 'You are not permitted to edit costumes.'
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
      }
    });
    if (msg === '') {
      status = 'success';
      msg = 'Costume edited successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/getCostume", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var costume = {};

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.user_id)) {
          if (project.data()['roles'][body.user_id]['permissions']['costumes']['view']) {
            const cos = await t.get(db.collection('projects').doc(body['project_id']).collection('Costumes').doc(body['id']));
            if (cos.exists) {
              status = 'success';
              costume = cos.data();
              msg = 'Got Costume successfully.';
            } else {
              status = 'failure';
              msg = 'Costume does not exist.'
              costume = {};
            }
          } else {
            status = 'failure';
            msg = 'You are not permitted to view costumes.'
            costume = {};
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          costume = {};
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        costume = {};
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
    costume = {};
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
    'costume': costume
  });
});

cinemawala.post("/getCostumes", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var costumes = [];

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.user_id)) {
          if (project.data()['roles'][body.user_id]['permissions']['costumes']['view']) {
            const costs = await t.get(db.collection('projects').doc(body['project_id']).collection('Costumes'));
            costs.docs.forEach(doc => {
              costumes.push(doc.data());
            });
            status = 'success';
            msg = 'Got Costumes successfully.';
          } else {
            status = 'failure';
            msg = 'You are not permitted to view costumes.'
            costumes = [];
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.';
          costumes = [];
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.';
        costumes = [];
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
    costumes = [];
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
    'costumes': costumes
  });
});

//Props

cinemawala.post("/addProp", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.added_by)) {
          if (project.data()['roles'][body.added_by]['permissions']['props']['add']) {
            t.set(db.collection('projects').doc(body['project_id']).collection('Props').doc(body['id']), body);
          } else {
            status = 'failure';
            msg = 'You are not permitted to add props.'
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
      }
    });
    if (msg === '') {
      status = 'success';
      msg = 'Prop added successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/editProp", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.last_edit_by)) {
          if (project.data()['roles'][body.last_edit_by]['permissions']['props']['edit']) {
            t.set(db.collection('projects').doc(body['project_id']).collection('Props').doc(body['id']), body);
          } else {
            status = 'failure';
            msg = 'You are not permitted to edit props.'
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
      }
    });
    if (msg === '') {
      status = 'success';
      msg = 'Prop edited successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/getProp", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var prop = {};

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.user_id)) {
          if (project.data()['roles'][body.user_id]['permissions']['props']['view']) {
            const doc = await t.get(db.collection('projects').doc(body['project_id']).collection('Props').doc(body['id']));
            if (doc.exists) {
              status = 'success';
              prop = doc.data();
              msg = 'Got Prop successfully.';
            } else {
              status = 'failure';
              msg = 'Prop does not exist.'
              prop = {};
            }
          } else {
            status = 'failure';
            msg = 'You are not permitted to view props.'
            prop = {};
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          prop = {};
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        prop = {};
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
    prop = {};
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
    'prop': prop
  });
});

cinemawala.post("/getProps", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var props = [];

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.user_id)) {
          if (project.data()['roles'][body.user_id]['permissions']['props']['view']) {
            const docs = await t.get(db.collection('projects').doc(body['project_id']).collection('Props'));
            docs.docs.forEach(doc => {
              props.push(doc.data());
            });
            status = 'success';
            msg = 'Got Props successfully.';
          } else {
            status = 'failure';
            msg = 'You are not permitted to view props.'
            props = [];
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.';
          props = [];
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.';
        props = [];
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
    props = [];
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
    'props': props
  });
});

//Location

cinemawala.post("/addLocation", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.added_by)) {
          if (project.data()['roles'][body.added_by]['permissions']['locations']['add']) {
            t.set(db.collection('projects').doc(body['project_id']).collection('Locations').doc(body['id']), body);
          } else {
            status = 'failure';
            msg = 'You are not permitted to add locations.'
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
      }
    });
    if (msg === '') {
      status = 'success';
      msg = 'Location added successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/editLocation", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.last_edit_by)) {
          if (project.data()['roles'][body.last_edit_by]['permissions']['locations']['edit']) {
            t.set(db.collection('projects').doc(body['project_id']).collection('Locations').doc(body['id']), body);
          } else {
            status = 'failure';
            msg = 'You are not permitted to edit locations.'
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
      }
    });
    if (msg === '') {
      status = 'success';
      msg = 'Location edited successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/getLocation", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var location = {};

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.user_id)) {
          if (project.data()['roles'][body.user_id]['permissions']['locations']['view']) {
            const doc = await t.get(db.collection('projects').doc(body['project_id']).collection('Locations').doc(body['id']));
            if (doc.exists) {
              status = 'success';
              location = doc.data();
              msg = 'Got Location successfully.';
            } else {
              status = 'failure';
              msg = 'Location does not exist.'
              location = {};
            }
          } else {
            status = 'failure';
            msg = 'You are not permitted to view locations.'
            location = {};
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          location = {};
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        location = {};
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
    location = {};
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
    'location': location
  });
});

cinemawala.post("/getLocations", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var locations = [];

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.user_id)) {
          if (project.data()['roles'][body.user_id]['permissions']['locations']['view']) {
            const docs = await t.get(db.collection('projects').doc(body['project_id']).collection('Locations'));
            docs.docs.forEach(doc => {
              locations.push(doc.data());
            });
            status = 'success';
            msg = 'Got Locations successfully.';
          } else {
            status = 'failure';
            msg = 'You are not permitted to view locations.'
            locations = [];
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.';
          locations = [];
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.';
        locations = [];
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
    locations = [];
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
    'locations': locations
  });
});

//Scenes

cinemawala.post("/addScene", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body["scene"]['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body["scene"]["added_by"])) {
          if (project.data()['roles'][body["scene"]["added_by"]]['permissions']['scenes']['add']) {
            const batch = db.batch();
            // console.log(body['scene']);
            batch.set(db.collection('projects').doc(body['scene']['project_id']).collection('Scenes').doc(body['scene']['id']), body["scene"]);

            if (project.data()['roles'][body["scene"]["added_by"]]['permissions']['casting']['edit']) {
              body["artists"].forEach(artist => {
                // console.log(artist);
                batch.set(db.collection('projects').doc(artist['project_id']).collection('Artists').doc(artist['id']), artist);
              });
            }

            if (project.data()['roles'][body["scene"]["added_by"]]['permissions']['costumes']['edit']) {
              body["costumes"].forEach(costume => {
                // console.log(costume);
                batch.set(db.collection('projects').doc(costume['project_id']).collection('Costumes').doc(costume['id']), costume);
              });
            }

            if (project.data()['roles'][body["scene"]["added_by"]]['permissions']['props']['edit']) {
              body["props"].forEach(prop => {
                // console.log(prop);
                batch.set(db.collection('projects').doc(prop['project_id']).collection('Props').doc(prop['id']), prop);
              });
            }

            if (project.data()['roles'][body["scene"]["added_by"]]['permissions']['locations']['edit']) {
              body["locations"].forEach(location => {
                // console.log(location);
                batch.set(db.collection('projects').doc(location['project_id']).collection('Locations').doc(location['id']), location);
              });
            }

            await batch.commit();

          } else {
            status = 'failure';
            msg = 'You are not permitted to add scenes.'
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
      }
    });
    if (msg === '') {
      status = 'success';
      msg = 'Scene added successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/editScene", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  console.log(body);

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body["scene"]['project_id']));
      console.log(body["scene"]['project_id']);
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body["scene"]["last_edit_by"])) {
          if (project.data()['roles'][body["scene"]["last_edit_by"]]['permissions']['scenes']['edit']) {
            const batch = db.batch();
            // console.log(body['scene']);
            batch.set(db.collection('projects').doc(body['scene']['project_id']).collection('Scenes').doc(body['scene']['id']), body["scene"]);

            if (project.data()['roles'][body["scene"]["last_edit_by"]]['permissions']['casting']['edit']) {
              body["artists"].forEach(artist => {
                // console.log(artist);
                batch.set(db.collection('projects').doc(artist['project_id']).collection('Artists').doc(artist['id']), artist);
              });
            }

            if (project.data()['roles'][body["scene"]["last_edit_by"]]['permissions']['costumes']['edit']) {
              body["costumes"].forEach(costume => {
                // console.log(costume);
                batch.set(db.collection('projects').doc(costume['project_id']).collection('Costumes').doc(costume['id']), costume);
              });
            }

            if (project.data()['roles'][body["scene"]["last_edit_by"]]['permissions']['props']['edit']) {
              body["props"].forEach(prop => {
                // console.log(prop);
                batch.set(db.collection('projects').doc(prop['project_id']).collection('Props').doc(prop['id']), prop);
              });
            }

            if (project.data()['roles'][body["scene"]["last_edit_by"]]['permissions']['locations']['edit']) {
              body["locations"].forEach(location => {
                // console.log(location);
                batch.set(db.collection('projects').doc(location['project_id']).collection('Locations').doc(location['id']), location);
              });
            }

            await batch.commit();

          } else {
            status = 'failure';
            msg = 'You are not permitted to edit scenes.'
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
      }
    });
    if (msg === '') {
      status = 'success';
      msg = 'Scene edited successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/getScene", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var scene = {};

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.user_id)) {
          if (project.data()['roles'][body.user_id]['permissions']['scenes']['view']) {
            const doc = await t.get(db.collection('projects').doc(body['project_id']).collection('Scenes').doc(body['id']));
            if (doc.exists) {
              status = 'success';
              scene = doc.data();
              msg = 'Got Scene successfully.';
            } else {
              status = 'failure';
              msg = 'Scene does not exist.'
              scene = {};
            }
          } else {
            status = 'failure';
            msg = 'You are not permitted to view scenes.'
            scene = {};
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          scene = {};
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        scene = {};
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
    scene = {};
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
    'scene': scene
  });
});

cinemawala.post("/getScenes", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var scenes = [];

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.user_id)) {
          if (project.data()['roles'][body.user_id]['permissions']['scenes']['view']) {
            const docs = await t.get(db.collection('projects').doc(body['project_id']).collection('Scenes'));
            docs.docs.forEach(doc => {
              scenes.push(doc.data());
            });
            status = 'success';
            msg = 'Got Scenes successfully.';
          } else {
            status = 'failure';
            msg = 'You are not permitted to view scenes.'
            scenes = [];
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.';
          scenes = [];
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.';
        scenes = [];
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
    scenes = [];
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
    'scenes': scenes
  });
});

//Schedule

cinemawala.post("/addSchedule", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.added_by)) {
          if (project.data()['roles'][body.added_by]['permissions']['schedule']['add']) {
            t.set(db.collection('projects').doc(body['project_id']).collection('Schedules').doc(body['id']), body);
          } else {
            status = 'failure';
            msg = 'You are not permitted to add schedules.'
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
      }
    });
    if (msg === '') {
      status = 'success';
      msg = 'Schedule added successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/addScheduleName", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.added_by)) {
          if (project.data()['roles'][body.added_by]['permissions']['schedule']['add']) {
            t.update(db.collection('projects').doc(body['project_id']), { "schedules": admin.firestore.FieldValue.arrayUnion(body.schedule) });
          } else {
            status = 'failure';
            msg = 'You are not permitted to add schedules.'
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
      }
    });
    if (msg === '') {
      status = 'success';
      msg = 'Schedule added successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/editSchedule", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.last_edit_by)) {
          if (project.data()['roles'][body.last_edit_by]['permissions']['schedule']['edit']) {
            t.set(db.collection('projects').doc(body['project_id']).collection('Schedules').doc(body['id']), body);
          } else {
            status = 'failure';
            msg = 'You are not permitted to edit schedules.'
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
      }
    });
    if (msg === '') {
      status = 'success';
      msg = 'Schedule edited successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/getSchedule", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var schedule = {};

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.user_id)) {
          if (project.data()['roles'][body.user_id]['permissions']['schedule']['view']) {
            const doc = await t.get(db.collection('projects').doc(body['project_id']).collection('Schedules').doc(body['id']));
            if (doc.exists) {
              status = 'success';
              schedule = doc.data();
              msg = 'Got Schedule successfully.';
            } else {
              status = 'failure';
              msg = 'Schedule does not exist.'
              schedule = {};
            }
          } else {
            status = 'failure';
            msg = 'You are not permitted to view schedules.'
            schedule = {};
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          schedule = {};
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        schedule = {};
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
    schedule = {};
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
    'schedule': schedule
  });
});

cinemawala.post("/getSchedules", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var schedules = [];

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.user_id)) {
          if (project.data()['roles'][body.user_id]['permissions']['schedule']['view']) {
            const docs = await t.get(db.collection('projects').doc(body['project_id']).collection('Schedules'));
            docs.docs.forEach(doc => {
              schedules.push(doc.data());
            });
            status = 'success';
            msg = 'Got Schedules successfully.';
          } else {
            status = 'failure';
            msg = 'You are not permitted to view schedules.'
            schedules = [];
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.';
          schedules = [];
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.';
        schedules = [];
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
    schedules = [];
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
    'schedules': schedules
  });
});

//Roles

cinemawala.post("/addRole", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.added_by)) {
          if (project.data()['roles'][body.added_by]['permissions']['roles']['add']) {
            var roles = {};
            roles[`${body.user_id}`] = body;
            var roleIds = project.data()['roles_ids'];
            if (!roleIds.includes(body.user_id)) {
              roleIds.push(body.user_id);
            }
            t.set(db.collection('projects').doc(body['project_id']), { roles, "roles_ids": roleIds }, { merge: true });
            var te = {};
            te["projects." + body['project_id']] = { id: body.project_id, role: body.role, owner: false, accepted: false }
            // console.log(te);
            t.update(db.collection('users').doc(body['user_id']), te);
          } else {
            status = 'failure';
            msg = 'You are not permitted to add roles.'
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
      }
    });
    if (msg === '') {
      status = 'success';
      msg = 'Role added successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/editRole", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.last_edit_by)) {
          if (project.data()['roles'][body.last_edit_by]['permissions']['roles']['edit']) {
            var roles = {};
            roles[`${body.user_id}`] = body;
            var roleIds = project.data()['roles_ids'];
            if (!roleIds.includes(body.user_id)) {
              roleIds.push(body.user_id);
            }
            t.set(db.collection('projects').doc(body['project_id']), { roles, "roles_ids": roleIds }, { merge: true });
          } else {
            status = 'failure';
            msg = 'You are not permitted to edit roles.'
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
      }
    });
    if (msg === '') {
      status = 'success';
      msg = 'Role edited successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/respondRole", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.user_id)) {
          if (body.accepted) {

            var te = {};
            te["roles." + body.user_id + ".accepted"] = true;
            // console.log(te);
            t.update(db.collection('projects').doc(body['project_id']), te);
            te = {};
            te["projects." + body.project_id + ".accepted"] = true;
            // console.log(te);
            t.update(db.collection('users').doc(body['user_id']), te);

          } else {

            var te = {};
            te["roles." + body.user_id] = admin.firestore.FieldValue.delete();
            te["roles_ids"] = admin.firestore.FieldValue.arrayRemove(body.user_id);
            // console.log(te);
            t.update(db.collection('projects').doc(body['project_id']), te);
            te = {};
            te["projects." + body.project_id] = admin.firestore.FieldValue.delete();
            // console.log(te);
            t.update(db.collection('users').doc(body['user_id']), te);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
      }
    });
    if (msg === '') {
      status = 'success';
      msg = 'Role edited successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

//DailyBudget

cinemawala.post("/addDailyBudget", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.added_by)) {
          if (project.data()['roles'][body.added_by]['permissions']['budget']['add']) {
            t.set(db.collection('projects').doc(body.project_id).collection('DailyBudgets').doc(body.id), body);
          } else {
            status = 'failure';
            msg = 'You are not permitted to add daily_budgets.'
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
      }
    });
    if (msg === '') {
      status = 'success';
      msg = 'DailyBudget added successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/editDailyBudget", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.last_edit_by)) {
          if (project.data()['roles'][body.last_edit_by]['permissions']['budget']['edit']) {
            t.set(db.collection('projects').doc(body['project_id']).collection('DailyBudgets').doc(body['id']), body);
          } else {
            status = 'failure';
            msg = 'You are not permitted to edit daily_budgets.'
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
      }
    });
    if (msg === '') {
      status = 'success';
      msg = 'DailyBudget edited successfully.';
    }
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/getDailyBudget", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var daily_budget = {};

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.user_id)) {
          if (project.data()['roles'][body.user_id]['permissions']['budget']['view']) {
            const doc = await t.get(db.collection('projects').doc(body['project_id']).collection('DailyBudgets').doc(body['id']));
            if (doc.exists) {
              status = 'success';
              daily_budget = doc.data();
              msg = 'Got DailyBudget successfully.';
            } else {
              status = 'failure';
              msg = 'DailyBudget does not exist.'
              daily_budget = {};
            }
          } else {
            status = 'failure';
            msg = 'You are not permitted to view daily_budgets.'
            daily_budget = {};
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          daily_budget = {};
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        daily_budget = {};
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
    daily_budget = {};
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
    'daily_budget': daily_budget
  });
});

cinemawala.post("/getDailyBudgets", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var daily_budgets = [];

  try {
    await db.runTransaction(async (t) => {
      const project = await t.get(db.collection('projects').doc(body['project_id']));
      if (project.exists) {
        if (project.data()['roles_ids'].includes(body.user_id)) {
          if (project.data()['roles'][body.user_id]['permissions']['budget']['view']) {
            const docs = await t.get(db.collection('projects').doc(body['project_id']).collection('DailyBudgets'));
            docs.docs.forEach(doc => {
              daily_budgets.push(doc.data());
            });
            status = 'success';
            msg = 'Got DailyBudgets successfully.';
          } else {
            status = 'failure';
            msg = 'You are not permitted to view daily_budgets.'
            daily_budgets = [];
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.';
          daily_budgets = [];
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.';
        daily_budgets = [];
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong. ' + e;
    daily_budgets = [];
  }
  res.status(200).send({
    'msg': msg,
    'status': status,
    'daily_budgets': daily_budgets
  });
});

exports.cinemawala = functions.https.onRequest(cinemawala);