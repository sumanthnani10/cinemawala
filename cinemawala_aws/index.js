const express = require('express');
const crypto = require('crypto');
var MongoClient = require("mongodb").MongoClient;
const multer = require('multer');
const admin = require('firebase-admin');
const path = require("path");
const fs = require("fs");
const cors = require('cors');

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
const auth = admin.auth();

var mongodbUrl = "mongodb://localhost:27017/";
var db;
var mongodb;

const cinemawala = express();

cinemawala.use(express.urlencoded({ extended: true }))
cinemawala.use(express.json())
cinemawala.use(cors())
cinemawala.use('/images', express.static('images'));

var storage = multer.diskStorage({
  destination: (req, file, callback) => {

    logger(req.headers.call_id, `Upload Image details - project: ${req.body.project_id}, id: ${req.body.id}, user: ${req.body.user_id}, type: ${req.body.type}.`);

    var path = "./images/" + req.body.type;
    logger(req.headers.call_id, `Path: ${path}`);
    callback(null, path);

  },
  filename: async (req, file, callback) => {
    var body = req.body;
    var session;
    var success = false;
    var msg = "";
    var fname = "errofile";

    try {

      session = mongodb.startSession();
      var projectImage = false;
      projectImage = (body.type==="projects" && body.process==="add");
      
      await session.withTransaction(async () => {
        if(!projectImage) {
          const project = await db.collection('projects').findOne({ id: body['project_id'] });  
          if (project !== null) {
            if (project['roles_ids'].includes(body.user_id)) {
              if (project.owner_id === body.user_id || project['roles'][body.user_id]['permissions'][body.type][body.process]) {

                fname = `${req.body.project_id}`;
                if(body.type !=="projects"){
                  fname += `_${req.body.id}`;
                }
                if (req.headers['data-type'] === "images") {
                  fname += `_${file.fieldname.split("_").pop()}_`;
                  var cryp = crypto.randomBytes(2);
                  fname += cryp.toString('hex');
                }
                fname += ".png";

                logger(req.headers.call_id, `File Name: ${fname}`);
                success = true;
                msg = "Image uploaded succesfully.";

              } else {
                success = false;
                msg = "User not permitted.";
                logger(req.headers.call_id, `${msg}`);
                fname = "errofile";
              }
            } else {
              success = false;
              msg = "User not a member.";
              logger(req.headers.call_id, `${msg}`);
              fname = "errofile";
            }
          } else {
            success = false;
            msg = "Project doesn't exists.";
            logger(req.headers.call_id, `${msg}`);
            fname = "errofile";
          }
        } else {
          logger(req.headers.call_id, `Add Project Image.`);

          fname = `${req.body.project_id}`;
          if (req.headers['data-type'] === "images") {
            fname += `_${file.fieldname.split("_").pop()}_`;
            var cryp = crypto.randomBytes(2);
            fname += cryp.toString('hex');
          }
          fname += ".png";

          logger(req.headers.call_id, `File Name: ${fname}`);
          success = true;
          msg = "Image uploaded succesfully.";

        }
      });
    } catch (e) {
      success = false;
      msg = "Something went wrong.";
      logger(req.headers.call_id, `${e}`);
      fname = "errofile";
    } finally {
      await session.endSession();
      req.body.msg = msg;
      req.body.success = success;
      callback(null, fname);
    }
  }
});

async function logger(callId, content) {
  console.log(`${callId}: ${content.toString()}`);
  // fileLogger.log(`\n${callId}: ${content.toString()}`);
  
  if (content === "end") {
    console.log("-------------------------------------------------------------------------");
    // fileLogger.log("\n-------------------------------------------------------------------------");
  }
}

const upload = multer({ storage: storage }).single('image_file');
const uploadMultiple = multer({ storage: storage }).fields([{name: 'image_files_1', maxCount: 1}, {name: 'image_files_2', maxCount: 1}, {name: 'image_files_3', maxCount: 1}, {name: 'image_files_4', maxCount: 1}, ]);


var basicKeys = {
  'casting': ["id", "project_id", "names", "characters", "image"], 
  'costumes': ["id", "project_id", "title", "reference_image"], 
  'locations': ["id", "project_id", "location", "shoot_location", "images"], 
  'props': ["id", "project_id", "title", "reference_image"], 
  'scenes': ["id", "project_id", "titles"], 
  'budget': ["id", "project_id"], 
  'schedule': ["id", "project_id", "day", "month", "year"],            
}

cinemawala.use(async (req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  res.header(
    "Access-Control-Allow-Headers",
    "Origin, X-Requested-With, Content-Type, Accept"
  );

  var temp = Date.now().toString() + "_";
  crypto.randomBytes(2, (e, r) => {
    if (e) temp += "1234";
    else temp += r.toString('hex');
    req.headers['call_id'] = temp;

    logger(req.headers['call_id'], "Call Started.");

    MongoClient.connect(mongodbUrl, { useNewUrlParser: true, useUnifiedTopology: true }, function (err, database) {
      if (err) throw err;

      mongodb = database;
      db = database.db("test");
      logger(req.headers['call_id'], "Mongodb Client Connected.");

      if (req.headers['data-type'] === "image" || req.headers['data-type'] === "images") {
        logger(req.headers['call_id'], `Image Data Type`);
      }

      next();
    });
  });

});

cinemawala.post("/uploadImage", async (req, res) => {

  logger(req.headers.call_id, `Upload Image started.`);

  upload(req, res, async (err) => {
    if (err) {
      logger(req.headers.call_id, `Error uploading file. ${err}`);
      logger(req.headers.call_id, `end`);
      await mongodb.close();
      return res.send({ "status": "failure", "msg": "Error uploading file." });
    }
    logger(req.headers.call_id, `end`);
    var body = req.body;
    if(body.success){
      var link = "https://cinemawala.in/" + req.file.path.replace(/\\/g,"/");
      res.send({ "status": "success", "msg": "Image is uploaded successfully.","link": link });
    } else {
      res.send({ "status": "failure", "msg": body.msg,"link": "" });
    }
    await mongodb.close();
  });

});

cinemawala.post("/uploadImages", async (req, res) => {

  logger(req.headers.call_id, `Upload Images started.`);

  uploadMultiple(req, res, async (err) => {
    if (err) {
      logger(req.headers.call_id, `Error uploading file. ${err}`);
      logger(req.headers.call_id, `end`);
      res.send({ "status": "failure", "msg": "Error uploading file." });
      await mongodb.close();
      return 1;
    }
    logger(req.headers.call_id, `end`);
    var body = req.body;
    if(body.success){
      var links = [];
      Object.keys(req.files).map((key) => {
        links.push("https://cinemawala.in/"+req.files[key][0].path.replace(/\\/g,"/"));
      });
      res.send({ "status": "success", "msg": "Image is uploaded successfully.","links": links });
    } else {
      res.send({ "status": "failure", "msg": body.msg,"link": "" });
    }
    await mongodb.close();
  });

});

cinemawala.post("/test", async (req, res) => {
  res.send("Done");
});

async function validateUsername(username) {
  try {
    var u = await db.collection("data").findOne({ id: "users" });
    var us = u["usernames"];
    var usernames = Object.keys(us).map(function (key) {
      return us[key][0];
    });
    return !usernames.includes(username);
  } catch (e) {
    logger(req.headers.call_id, `${e}`);
    return false;
  }
}

cinemawala.post("/validateUsername", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var valid = false;

  try {

    logger(req.headers.call_id, "validateUsername - username: " + body.username);

    if (await validateUsername(body.username)) {

      logger(req.headers.call_id, body.username + " is valid");

      status = 'success';
      msg = 'User Id is valid';
      valid = true;
    } else {

      logger(req.headers.call_id, body.username + " is not valid");

      status = 'failure';
      msg = 'User Id is already used.';
      valid = false;
    }
  } catch (e) {
    logger(req.headers.call_id, e);
    status = 'failure';
    msg = 'User Id is already used.';
    valid = false;
  }

  logger(req.headers.call_id, `end`);
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

    logger(req.headers.call_id, "getAllUsernames - by: " + body.user_id);

    var u = await db.collection("data").findOne({ id: "users" });
    var us = u["usernames"];
    var usernames = [];
    for (const [key, value] of Object.entries(us)) {
      usernames.push({ "username": value[0], "name": value[1], "id": key })
    }
    logger(req.headers.call_id, "Got All Usernames Successfully. Length: " + usernames.length);
    status = 'success';
    msg = "Got Usernames successfully";
  } catch (e) {
    logger(req.headers.call_id, "Get All Usernames Failed by: " + e);
    status = 'failure';
    msg = "Usernames get successfully ";
  }

  logger(req.headers.call_id, `end`);

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

  var session;

  try {
    logger(req.headers.call_id, `getUser userID: ${body.id}`);
    session = mongodb.startSession();
    await session.withTransaction(async () => {
      const usr = await db.collection('users').findOne({ id: body.id });
      if (usr !== null) {
        logger(req.headers.call_id, `User got succesfully.`);
        status = 'success';
        user = usr;
        msg = 'Got User successfully.';
      } else {
        logger(req.headers.call_id, `User doesn't exist.`);
        status = 'failure';
        msg = 'User details does not exist. Please Register'
        user = {};
      }
    });
  } catch (e) {
    logger(req.headers.call_id, `Error: ${e}`);
    status = 'failure';
    msg = 'Something went wrong. ';
    user = {};
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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

  var session;

  try {

    logger(req.headers.call_id, `addUser Started.`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const u = await db.collection("data").findOne({ id: "users" });
      var usernames = Object.keys(u).map(function (key) {
        return u[key][0];
      });
      if (!usernames.includes(body.username)) {
        logger(req.headers.call_id, `Username is Valid.`);
        await auth.createUser({
          email: body.email,
          emailVerified: false,
          phoneNumber: body.mobile,
          password: body.password,
          displayName: body.name,
          uid: body.id,
          disabled: false,
        }).then(async (userRecord) => {
          logger(req.headers.call_id, `User auth created.`);
          delete body['password']
          await db.collection('users').insertOne(body);
          var usbo = {};
          usbo["usernames." + `${body.id}`] = [body.username, body.name];

          await db.collection('data').updateOne({ id: "users" }, { $set: usbo }, { upsert: true });

          logger(req.headers.call_id, `User inserted into Database.`);
          status = "success";
          msg = "User added succesfully";
        }).catch((error) => {
          status = 'failure';

          logger(req.headers.call_id, `Add user Error: ${error}`);

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
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    logger(req.headers.call_id, `${e}`);
    status = 'failure';
    msg = 'Something went wrong. ';
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/userForgotPassword", async (req, res) => {
  var body = req.body;
  var msg = 'Something went wrong.';
  var status = 'failure';

  logger(req.headers.call_id, `forgot password started for email: ${body.email}, user: ${body.user_id}`);

  try {
    await auth.generatePasswordResetLink(body.email);
    logger(req.headers.call_id, `email sent.`);
  } catch (e) {
    logger(req.headers.call_id, `${e}`);
    status = 'failure';
    msg = 'Something went wrong. ';
  }

  logger(req.headers.call_id, `end.`);

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
  var session;

  try {

    logger(req.headers.call_id, `Add Note. user: ${body.user_id}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const user = await db.collection('users').findOne({ id: body['user_id'] });
      if (user !== null) {
        var te = { "$set": {} };
        var note = body.note;
        var new_note = note.notes;
        var old_notes = [];
        if (user.notes[note.id] !== undefined) {
          old_notes = user.notes[note.id]['notes'];
        }
        old_notes.push(new_note);
        note['notes'] = Array.from(new Set(old_notes));

        te['$set']['notes.' + note.id] = note;

        await db.collection('users').updateOne({ id: body['user_id'] }, te);

        logger(req.headers.call_id, `Note Inserted.`);
        status = 'success';
        msg = 'Note added successfully.';

      } else {
        status = 'failure';
        msg = 'User does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/removeNote", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var session;

  try {

    logger(req.headers.call_id, `Remove Note Started. note: ${body.note.notes}, user: ${body.user_id}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const user = await db.collection('users').findOne({ id: body['user_id'] });
      if (user !== null) {
        var te = { "$set": {} };
        var note = body.note;
        var old_note = note.notes;
        var old_notes = [];
        if (user.notes[note.id] !== undefined) {
          old_notes = user.notes[note.id]['notes'];
        }
        var ind = old_notes.indexOf(old_note);

        console.log(old_notes);
        console.log(ind);
        if (ind > -1) {
          old_notes.splice(ind, 1);
        }
        console.log(old_notes);
        note['notes'] = Array.from(new Set(old_notes));

        te['$set']['notes.' + note.id] = note;

        await db.collection('users').updateOne({ id: body['user_id'] }, te);

        status = 'success';
        msg = 'Note removed successfully.';
        logger(req.headers.call_id, `${msg}`);
      } else {
        status = 'failure';
        msg = 'User does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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

  var session;

  try {

    logger(req.headers.call_id, `add project started user: ${body.owner_id}, project_id: ${body.id}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      await db.collection('projects').updateOne({ id: body['id'] }, { "$set": body }, { upsert: true });

      logger(req.headers.call_id, `project ${body.id} inserted`);

      var te = {};
      te["$set"] = {};
      te["$set"]["projects." + body['id']] = { id: body.id, role: "Owner", owner: true, accepted: true };
      await db.collection('users').updateOne({ id: body.owner_id }, te, { upsert: true });
      logger(req.headers.call_id, `user projects inserted`);

      logger(req.headers.call_id, `project added successfully`);
      status = 'success';
      msg = 'Project added successfully.';
    });
  } catch (e) {
    logger(req.headers.call_id, `${e}`);
    status = 'failure';
    msg = 'Something went wrong.';
  } finally {
    await session.endSession();
    await mongodb.close();
  }
  logger(req.headers.call_id, `end`);
  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/editProject", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  var session;

  try {

    logger(req.headers.call_id, `Edit project started user: ${body.owner_id}, project: ${body.id}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['id'], project_id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.last_edit_by)) {
          if (project['roles'][body.last_edit_by]['owner']) {
            var proj = {...project,...body};
            await db.collection('projects').updateOne({ id: body['id'] }, { "$set": proj });
            logger(req.headers.call_id, `Project Edited Succesfully.`);
            status = 'success';
            msg = 'Project edited successfully.';
          } else {
            logger(req.headers.call_id, `User not permitted to edit project.`);
            status = 'failure';
            msg = 'You are not permitted to edit project.'
          }
        } else {
          logger(req.headers.call_id, `User Not member of the project.`);
          status = 'failure';
          msg = 'You are not a member of this project.'
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    logger(req.headers.call_id, `${e}`);
    status = 'failure';
    msg = 'Something went wrong.';
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/getProjects", async (req, res) => {
  var body = req.body;
  var user_id = body['user_id'];
  var msg = '';
  var status = '';
  var projects = [];

  logger(req.headers.call_id, `Get Projects Started.`);

  try {
    await db.collection('projects').find({ roles_ids: user_id }).toArray().then((snaps) => {
      snaps.forEach((d) => {
        var role = d['roles'][user_id];
        delete d['roles'];
        delete d['roles_ids'];
        delete d['artists'];
        delete d['artist_ids'];
        d['roles'] = {};
        d['roles'][user_id] = role;
        d['roles_ids'] = [body.user_id];
        projects.push(d);
      })
      status = "success";
      msg = "Got Projects Successfully.";
    }).catch((e) => { logger(req.headers.call_id, `${e}`); });
  } catch (e) {
    logger(req.headers.call_id, `${e}`);
    status = "failure";
    msg = "Something went wrong..";
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'status': status,
    'msg': msg,
    'projects': projects
  });
});

cinemawala.post("/getProject", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var project = {};

  var session;

  try {

    logger(req.headers.call_id, `Get Project Started.`);
    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const proj = await db.collection('projects').findOne({ id: body['project_id'] });
      if (proj !== null) {
        if (proj['roles_ids'].includes(body.user_id)) {
          status = 'success';
          if(!proj.roles[body.user_id]['permissions']['roles']['view']){
            var role = proj['roles'][body.user_id];
            delete proj['roles'];
            delete proj['roles_ids'];
            proj['roles'] = {};
            proj['roles'][body.user_id] = role;
            proj['roles_ids'] = [body.user_id];
          }
          if(!proj.roles[body.user_id]['permissions']['casting']['view']){
            delete proj['artists'];
            delete proj['artist_ids'];
          }
          project = proj;
          msg = 'Got Project successfully.';
          logger(req.headers.call_id, `Got Project.`);
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          project = {};
          logger(req.headers.call_id, `User not permitted.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        project = {};
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    logger(req.headers.call_id, `${e}`);
    status = 'failure';
    msg = 'Something went wrong.';
    project = {};
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'msg': msg,
    'status': status,
    'project': project
  });
});

cinemawala.post("/getCompleteProject", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var project = {};

  var session;

  try {

    logger(req.headers.call_id, `Get Complete Project Started.`);
    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const proj = await db.collection('projects').findOne({ id: body['project_id'] });
      if (proj !== null) {
        if (proj['roles_ids'].includes(body.user_id)) {
          status = 'success';
          var permissions = proj.roles[body.user_id]['permissions'];
          if(!permissions['roles']['view']){
            var role = proj['roles'][body.user_id];
            delete proj['roles'];
            delete proj['roles_ids'];
            proj['roles'] = {};
            proj['roles'][body.user_id] = role;
            proj['roles_ids'] = [body.user_id];
          }
          if(!permissions['casting']['view']){
            delete proj['artists'];
            delete proj['artist_ids'];
          }
          project['project'] = proj;

          var elements = [
            ['casting','Artists',['artists', 'addl_artists']], 
            ['costumes','Costumes',['costumes']], 
            ['locations','Locations',['location']], 
            ['props','Props',['props']], 
            ['scenes','Scenes',[]], 
            ['budget','DailyBudgets',[]], 
            ['schedule','Schedules',[]]];

          var basic_keys = {
            'casting': ["id", "project_id", "names", "characters", "image"], 
            'costumes': ["id", "project_id", "title", "reference_image"], 
            'locations': ["id", "project_id", "location", "shoot_location", "images"], 
            'props': ["id", "project_id", "title", "reference_image"], 
            'scenes': ["id", "project_id", "titles"], 
            'budget': ["id", "project_id"], 
            'schedule': ["id", "project_id", "day", "month", "year"],            
          }

          for(let i = 0;i < elements.length; i++){
            var e = elements[i];
            var docs = [];
            if(permissions[e[0]]['view']){
              basic_keys['scenes'] = basic_keys['scenes'].concat(e[2]);
              docs = await db.collection(e[1]).find({project_id: body['project_id']}).toArray();
            } else {
              var bdocs = await db.collection(e[1]).find({project_id: body['project_id']}).toArray();
              bdocs.forEach((doc) => {
                var d = {};
                basic_keys[e[0]].forEach((bk) => {
                  d[bk] = doc[bk];
                });
                docs.push(d);
              });
            }
            if(e[0] === 'casting'){
              docs.sort((a,b) => (a.created > b.created) ? 1 : ((b.created > a.created) ? -1 : 0));
            } else if(e[0] === 'costumes' || e[0] === 'props') {
              docs.sort((a,b) => (a.title > b.title) ? 1 : ((b.title > a.title) ? -1 : 0));
            }  else if(e[0] === 'locations') {
              docs.sort((a,b) => (a.location > b.location) ? 1 : ((b.location > a.location) ? -1 : 0));
            }   else if(e[0] === 'scenes') {
              docs.sort((a,b) => (a.titles.en > b.titles.en) ? 1 : ((b.titles.en > a.titles.en) ? -1 : 0));
            } 
            project[e[1].toLowerCase()] = docs;
          }

          msg = 'Got Complete Project successfully.';
          logger(req.headers.call_id, `Got Complete Project.`);
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          project = {};
          logger(req.headers.call_id, `User not permitted.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        project = {};
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    logger(req.headers.call_id, `${e}`);
    status = 'failure';
    msg = 'Something went wrong.';
    project = {};
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'msg': msg,
    'status': status,
    'project': project
  });
});

// Artist Project

cinemawala.post("/getArtistProjects", async (req, res) => {
  var body = req.body;
  var user_id = body['user_id'];
  var msg = '';
  var status = '';
  var projects = [];

  logger(req.headers.call_id, `Get Artist Project Started.`);

  try {
    const snaps = await db.collection('projects').find({ artist_ids: user_id }).toArray();
    snaps.forEach((d) => {
      delete d['roles'];
      delete d['roles_ids'];
      delete d['artists'];
      delete d['artist_ids'];
      projects.push(d);
    })
    status = "success";
    msg = "Got Artist Projects Successfully.";
  } catch (e) {
    logger(req.headers.call_id, `${e}`);
    status = "failure";
    msg = "Something went wrong..";
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'status': status,
    'msg': msg,
    'projects': projects
  });
});

cinemawala.post("/getArtistProject", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var project = {};
  var session;

  try {

    logger(req.headers.call_id, `Get Artist Project Started.`);

    session = mongodb.startSession();
    await session.withTransaction(async () => {
      const proj = await db.collection('projects').findOne({ id: body.project_id });
      if (proj !== null) {
        var artist_id = "";
        var aIds = proj["artists"];
        var i = Object.keys(aIds).map(function (key) {
          if (aIds[key] == body.user_id) {
            artist_id = key;
          }
          return aIds[key];
        });
        if (artist_id !== "") {

          delete proj['roles'];
          delete proj['roles_ids'];
          delete proj['artists'];
          delete proj['artist_ids'];

          project['project'] = proj;
          logger(req.headers.call_id, `Got Project.`);

          await db.collection('Artists').findOne({ id: artist_id }).then(async (act) => {
            if (act !== null) {
              var actor = act;
              project['actor'] = actor;

              var scenes = [];
              var costume_ids = [""];
              var location_ids = [""];
              var scene_ids = [""];

              await db.collection('Scenes').find({ artists: artist_id }).toArray().then((docs) => {
                docs.forEach(doc => {
                  scenes.push(doc);
                  scene_ids.push(doc['id']);
                  location_ids.push(doc['location']);
                  var c = doc['costumes'].find(e => e.id === artist_id);
                  if (c !== undefined)
                    costume_ids = costume_ids.concat(c.costumes);
                });
              }).catch((e) => { logger(req.headers.call_id, `${e}`); scenes = [] });

              project['scenes'] = scenes;

              location_ids = Array.from(new Set(location_ids));
              var locations = [];
              await db.collection('Locations').find({ id: { $in: location_ids } }).toArray().then((docs) => {
                docs.forEach(doc => {
                  locations.push(doc);
                });
              }).catch((e) => { logger(req.headers.call_id, `${e}`); locations = [] });
              project['locations'] = locations;

              costume_ids = Array.from(new Set(costume_ids));
              var costumes = [];
              await db.collection('Costumes').find({ id: { $in: costume_ids } }).toArray().then((docs) => {
                docs.forEach(doc => {
                  costumes.push(doc);
                });
              }).catch((e) => { logger(req.headers.call_id, `${e}`); costumes = [] });
              project['costumes'] = costumes;

              var schedules = [];
              await db.collection('Schedules').find({ scenes: { $in: scene_ids } }).toArray().then((docs) => {
                docs.forEach(doc => {
                  schedules.push(doc);
                });
              }).catch((e) => { logger(req.headers.call_id, `${e}`); schedules = [] });
              project['schedules'] = schedules;

              status = 'success';
              msg = 'Got Project successfully.';
              logger(req.headers.call_id, `${msg}`);
            } else {
              logger(req.headers.call_id, `Artist Dont exist.`);
              status = 'failure';
              msg = 'Artist does not exist.'
              actor = {};
            }
          }).catch((e) => { logger(req.headers.call_id, `${e}`); });

        } else {
          logger(req.headers.call_id, `User not permitted.`);
          status = 'failure';
          msg = 'You are not a member of this project.'
          project = {};
        }

      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        project = {};
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    logger(req.headers.call_id, `${e}`);
    status = 'failure';
    msg = 'Something went wrong.';
    project = {};
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);
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

  logger(req.headers.call_id, body);

  var text = "abcdefghijklmnopqrstuvwxyz";
  // text += "!@#$%^&*()";
  text += "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  // text += "`[]\;',./-=";
  text += "0123456789";
  // text += "~{}|:\"<>?";

  var length = text.length - 1;

  var session;

  try {

    logger(req.headers.call_id, `Generate Cast Code Started. user: ${body.user_id}`);
    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const user = await db.collection('users').findOne({ id: body['user_id'] });
      if (user !== null) {
        do {
          code = "";
          for (let i = 0; i < 10; i++) {
            var index = Math.ceil(Math.random() * length);
            if (index < 0 || index >= text.length) {
              index = 0
            }
            code += text[index];
          }
        } while (user["codes"][code === undefined]);

        if (code.length > 10) {
          code = code.substring(0, 10);
        }

        msg = "Code generated successfully";
        logger(req.headers.call_id, `Code generated successfully. ${code}`);

        var codeBody = {
          "$set": {}
        };
        codeBody["$set"]['codes.' + code] = {
          "code": code,
          "created": Date.now(),
          "used": false
        }

        await db.collection('users').updateOne({ id: body['user_id'] }, codeBody);

        logger(req.headers.call_id, `User Code Updated Successfully.`);

      } else {
        status = 'failure';
        msg = 'User does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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
  var session;

  try {

    logger(req.headers.call_id, `Validate Cast Code. code: ${body.code}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const user = await db.collection('users').findOne({ id: body['user_id'] });
      if (user !== null) {
        if (user['codes'][body.code] !== undefined) {
          var code = user['codes'][body.code];
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

          logger(req.headers.call_id, `${msg}`);

        } else {
          status = 'failure';
          msg = 'Invalid Code.'
          logger(req.headers.call_id, `${msg}`);
        }
      } else {
        status = 'failure';
        msg = 'User does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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
  var session;

  try {

    logger(req.headers.call_id, `Assign Cast. code: ${body.code}, project_id: ${body['project_id']}, username: ${body["username"]}, user: ${body["user_id"]}, artist_id:${body['id']}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.last_edit_by)) {
          if (project['roles'][body.last_edit_by]['permissions']['casting']['edit']) {
            if (!project['artist_ids'].includes(body['user_id'])) {

              await db.collection('Artists').updateOne({ id: body['id'] },
                { "$set": { "by": { "username": body["username"], "user_id": body["user_id"] } } });

              var ab = {
                "$addToSet": { "artist_ids": body.user_id },
                "$set": {}
              }

              ab['$set']["artists." + body.id] = body.user_id;
              await db.collection('projects').updateOne({ id: body['project_id'] }, ab);
              logger(req.headers.call_id, `Project updated`);

              ab = {};
              ab["acts_in." + body.project_id] = {
                "as": body.id,
                "code": body.code,
                "id": body.project_id
              };
              ab["codes." + body.code + ".used"] = true;
              ab = { "$set": ab };
              await db.collection('users').updateOne({ id: body['user_id'] }, ab);
              logger(req.headers.call_id, `User updated.`);

              status = 'success';
              msg = 'Cast assigned successfully.';


            } else {
              status = 'failure';
              msg = 'User already assigned.'
              logger(req.headers.call_id, `${msg}`);
            }
          } else {
            status = 'failure';
            msg = 'You are not permitted to remove cast.'
            logger(req.headers.call_id, `${msg}`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `${msg}`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/removeCast", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var session;

  try {

    logger(req.headers.call_id, `Remove Cast Started. project_id: ${body.project_id}, artist: ${body['id']}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.last_edit_by)) {
          if (project['roles'][body.last_edit_by]['permissions']['casting']['edit']) {
            await db.collection('Artists').updateOne({ id: body['id'] }, { "$set": { "by": { "username": "", "user_id": "" } } });

            var ab = {
              "$pullAll": { "artist_ids": [body.user_id] },
              "$unset": {}
            }
            ab["$unset"]["artists." + body.id] = "";
            await db.collection('projects').updateOne({ id: body['project_id'] }, ab);

            logger(req.headers.call_id, `Project updated.`);

            ab = { "$unset": {} };
            ab["$unset"]["acts_in." + body.project_id] = "";
            await db.collection('users').updateOne({ id: body['user_id'] }, ab);
            logger(req.headers.call_id, `User Updated.`);

            status = 'success';
            msg = 'Cast removed successfully.';

          } else {
            status = 'failure';
            msg = 'You are not permitted to remove cast.'
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end.`);

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

  var session;

  try {

    logger(req.headers.call_id, `Add Artist Started. id: ${body.id}, user: ${body.added_by}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.added_by)) {
          if (project['roles'][body.added_by]['permissions']['casting']['add']) {
            await db.collection('Artists').updateOne({ id: body.id, project_id: body.project_id }, { $set: body }, { upsert: true });
            status = 'success';
            msg = 'Artist added successfully.';
            logger(req.headers.call_id, `${msg}`);
          } else {
            status = 'failure';
            msg = 'You are not permitted to add artists.'
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/editArtist", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  var session;

  try {

    logger(req.headers.call_id, `Edit Artist Started. id: ${body.id}, user: ${body.last_edit_by}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.last_edit_by)) {
          if (project['roles'][body.last_edit_by]['permissions']['casting']['edit']) {
            await db.collection('Artists').updateOne({ id: body.id, project_id: body.project_id }, { $set: body });
            status = 'success';
            msg = 'Artist edited successfully.';
            logger(req.headers.call_id, `${msg}`);
          } else {
            status = 'failure';
            msg = 'You are not permitted to edit artists.'
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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
  var session;

  try {

    logger(req.headers.call_id, `Get Artist Started. id: ${body.id}, project: ${body.project_id}, user: ${body.user_id}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.user_id)) {
            const act = await db.collection('Artists').findOne({ id: body['id'], project_id: body['project_id'] });
            if (act !== null) {
              status = 'success';
              if (project['roles'][body.user_id]['permissions']['casting']['view']) {
                actor = act;
              } else {
                basicKeys["casting"].forEach((bk) => {
                  actor[bk] = act[bk];
                });
                logger(req.headers.call_id, `User not permitted.`);
              }
              msg = 'Got Artist successfully.';
            } else {
              status = 'failure';
              msg = 'Artist does not exist.'
              actor = {};
            }
            logger(req.headers.call_id, `${msg}`);
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          actor = {};
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        actor = {};
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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
  var session;

  try {

    logger(req.headers.call_id, `Get Artists Started. project: ${body.project_id}, user: ${body.user_id}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.user_id)) {
            const datas = await db.collection('Artists').find({ project_id: body['project_id'] }).toArray();
            datas.sort((a,b) => (a.created > b.created) ? 1 : ((b.created > a.created) ? -1 : 0));
            if (project['roles'][body.user_id]['permissions']['casting']['view']) {
              datas.forEach(doc => {
                actors.push(doc);
              });
            } else {
              datas.forEach((doc) => {
                var d = {};
                basicKeys["casting"].forEach((bk) => {
                  d[bk] = doc[bk];
                });
                actors.push(d);
              });
            logger(req.headers.call_id, `User not permitted.`);
          }
            status = 'success';
            msg = 'Got Artists successfully.';
            logger(req.headers.call_id, `${msg}`);
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.';
          actors = [];
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.';
        actors = [];
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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

  var session;

  try {

    logger(req.headers.call_id, `Add Costume Started. id: ${body.id}, user: ${body.added_by}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.added_by)) {
          if (project['roles'][body.added_by]['permissions']['costumes']['add']) {
            await db.collection('Costumes').updateOne({ id: body.id, project_id: body.project_id }, { $set: body }, { upsert: true });
            status = 'success';
            msg = 'Costume added successfully.';
            logger(req.headers.call_id, `${msg}`);
          } else {
            status = 'failure';
            msg = 'You are not permitted to add costumes.'
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/editCostume", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  var session;

  try {

    logger(req.headers.call_id, `Edit Costume Started. id: ${body.id}, user: ${body.last_edit_by}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.last_edit_by)) {
          if (project['roles'][body.last_edit_by]['permissions']['costumes']['edit']) {
            await db.collection('Costumes').updateOne({ id: body.id, project_id: body.project_id }, { $set: body });
            status = 'success';
            msg = 'Costume edited successfully.';
            logger(req.headers.call_id, `${msg}`);
          } else {
            status = 'failure';
            msg = 'You are not permitted to edit costumes.'
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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
  var session;

  try {

    logger(req.headers.call_id, `Get Costume Started. id: ${body.id}, project: ${body.project_id}, user: ${body.user_id}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.user_id)) {
            const act = await db.collection('Costumes').findOne({ id: body['id'], project_id: body['project_id'] });
            if (act !== null) {
              status = 'success';
              if (project['roles'][body.user_id]['permissions']['costumes']['view']) {
                costume = act;
              } else {
                basicKeys["costumes"].forEach((bk) => {
                  costume[bk] = act[bk];
                });
                logger(req.headers.call_id, `User not permitted.`);
              }
              msg = 'Got Costume successfully.';
            } else {
              status = 'failure';
              msg = 'Costume does not exist.'
              costume = {};
            }
            logger(req.headers.call_id, `${msg}`);
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          costume = {};
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        costume = {};
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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
  var session;

  try {

    logger(req.headers.call_id, `Get Costumes Started. project: ${body.project_id}, user: ${body.user_id}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.user_id)) {
            const datas = await db.collection('Costumes').find({ project_id: body['project_id'] }).toArray();
            datas.sort((a,b) => (a.title > b.title) ? 1 : ((b.title > a.title) ? -1 : 0));
            if (project['roles'][body.user_id]['permissions']['costumes']['view']) {
              datas.forEach(doc => {
                costumes.push(doc);
              });
            } else {
              datas.forEach((doc) => {
                var d = {};
                basicKeys["costumes"].forEach((bk) => {
                  d[bk] = doc[bk];
                });
                costumes.push(d);
              });
              logger(req.headers.call_id, `User not permitted.`);
            }
            status = 'success';
            msg = 'Got Costumes successfully.';
            logger(req.headers.call_id, `${msg}`);
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.';
          costumes = [];
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.';
        costumes = [];
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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

  var session;

  try {

    logger(req.headers.call_id, `Add Prop Started. id: ${body.id}, user: ${body.added_by}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.added_by)) {
          if (project['roles'][body.added_by]['permissions']['props']['add']) {
            await db.collection('Props').updateOne({ id: body.id, project_id: body.project_id }, { $set: body }, { upsert: true });
            status = 'success';
            msg = 'Prop added successfully.';
            logger(req.headers.call_id, `${msg}`);
          } else {
            status = 'failure';
            msg = 'You are not permitted to add props.'
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/editProp", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  var session;

  try {

    logger(req.headers.call_id, `Edit Prop Started. id: ${body.id}, user: ${body.last_edit_by}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.last_edit_by)) {
          if (project['roles'][body.last_edit_by]['permissions']['props']['edit']) {
            await db.collection('Props').updateOne({ id: body.id, project_id: body.project_id }, { $set: body });
            status = 'success';
            msg = 'Prop edited successfully.';
            logger(req.headers.call_id, `${msg}`);
          } else {
            status = 'failure';
            msg = 'You are not permitted to edit props.'
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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
  var session;

  try {

    logger(req.headers.call_id, `Get Prop Started. id: ${body.id}, project: ${body.project_id}, user: ${body.user_id}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.user_id)) {
            const act = await db.collection('Props').findOne({ id: body['id'], project_id: body['project_id'] });
            if (act !== null) {
              status = 'success';
              if (project['roles'][body.user_id]['permissions']['props']['view']) {
                prop = act;
              } else {
                basicKeys["props"].forEach((bk) => {
                  prop[bk] = act[bk];
                });
                logger(req.headers.call_id, `User not permitted.`);
              }
              msg = 'Got Prop successfully.';
            } else {
              status = 'failure';
              msg = 'Prop does not exist.'
              prop = {};
            }
            logger(req.headers.call_id, `${msg}`);
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          prop = {};
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        prop = {};
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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
  var session;

  try {

    logger(req.headers.call_id, `Get Props Started. project: ${body.project_id}, user: ${body.user_id}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.user_id)) {
            const datas = await db.collection('Props').find({ project_id: body['project_id'] }).toArray();
            datas.sort((a,b) => (a.title > b.title) ? 1 : ((b.title > a.title) ? -1 : 0));
            if (project['roles'][body.user_id]['permissions']['props']['view']) {
              datas.forEach(doc => {
                props.push(doc);
              });
            } else {
              datas.forEach((doc) => {
                var d = {};
                basicKeys["props"].forEach((bk) => {
                  d[bk] = doc[bk];
                });
                props.push(d);
              });
              logger(req.headers.call_id, `User not permitted.`);
            }
            status = 'success';
            msg = 'Got Props successfully.';
            logger(req.headers.call_id, `${msg}`);
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.';
          props = [];
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.';
        props = [];
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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

  var session;

  try {

    logger(req.headers.call_id, `Add Location Started. id: ${body.id}, user: ${body.added_by}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.added_by)) {
          if (project['roles'][body.added_by]['permissions']['locations']['add']) {
            await db.collection('Locations').updateOne({ id: body.id, project_id: body.project_id }, { $set: body }, { upsert: true });
            status = 'success';
            msg = 'Location added successfully.';
            logger(req.headers.call_id, `${msg}`);
          } else {
            status = 'failure';
            msg = 'You are not permitted to add locations.'
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/editLocation", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';

  var session;

  try {

    logger(req.headers.call_id, `Edit Location Started. id: ${body.id}, user: ${body.last_edit_by}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.last_edit_by)) {
          if (project['roles'][body.last_edit_by]['permissions']['locations']['edit']) {
            await db.collection('Locations').updateOne({ id: body.id, project_id: body.project_id }, { $set: body });
            status = 'success';
            msg = 'Location edited successfully.';
            logger(req.headers.call_id, `${msg}`);
          } else {
            status = 'failure';
            msg = 'You are not permitted to edit locations.'
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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
  var session;

  try {

    logger(req.headers.call_id, `Get Location Started. id: ${body.id}, project: ${body.project_id}, user: ${body.user_id}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.user_id)) {
            const act = await db.collection('Locations').findOne({ id: body['id'], project_id: body['project_id'] });
            if (act !== null) {
              status = 'success';
              if (project['roles'][body.user_id]['permissions']['locations']['view']) {
                location = act;
              } else {
                basicKeys["locations"].forEach((bk) => {
                  location[bk] = act[bk];
                });
                logger(req.headers.call_id, `User not permitted.`);
              }
              msg = 'Got Location successfully.';
            } else {
              status = 'failure';
              msg = 'Location does not exist.'
              location = {};
            }
            logger(req.headers.call_id, `${msg}`);
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          location = {};
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        location = {};
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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
  var session;

  try {

    logger(req.headers.call_id, `Get Locations Started. project: ${body.project_id}, user: ${body.user_id}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.user_id)) {
            const datas = await db.collection('Locations').find({ project_id: body['project_id'] }).toArray();
            datas.sort((a,b) => (a.location > b.location) ? 1 : ((b.location > a.location) ? -1 : 0));
            if (project['roles'][body.user_id]['permissions']['locations']['view']) {
              datas.forEach(doc => {
                locations.push(doc);
              });
            } else {
              datas.forEach((doc) => {
                var d = {};
                basicKeys["locations"].forEach((bk) => {
                  d[bk] = doc[bk];
                });
                locations.push(d);
              });
              logger(req.headers.call_id, `User not permitted.`);
            }
            status = 'success';
            msg = 'Got Locations successfully.';
            logger(req.headers.call_id, `${msg}`);
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.';
          locations = [];
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.';
        locations = [];
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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
  var session;

  try {

    logger(req.headers.call_id, `Add Scene Started. id: ${body.scene.id}, user: ${body.scene.added_by}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body["scene"]['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body["scene"]["added_by"])) {
          if (project['roles'][body["scene"]["added_by"]]['permissions']['scenes']['add']) {

            await db.collection('Scenes').updateOne({ id: body['scene'].id, project_id: body.scene.project_id }, { $set: body['scene'] }, { upsert: true });
            logger(req.headers.call_id, `Scene Added`);

            var keys = [
              ['artists','Artists','artists'], 
              ['costumes','Costumes','costumes'], 
              ['locations','Locations','locations'], 
              ['props','Props','props'], 
            ];

            for (let ind = 0; ind < keys.length; ind++) {
              const key = keys[ind];
              //if (project['roles'][body["scene"]["last_edit_by"]]['permissions'][key[2]]['edit']) {
                for (let i = 0; i < body[key[0]].length; i++) {
                  const obj = body[key[0]][i];
                  logger(req.headers.call_id, `Updating ${obj['id']}`);
                  await db.collection(key[1]).updateOne({ id: obj['id'], project_id: body.scene.project_id }, {"$set": obj});
                  logger(req.headers.call_id, `Updated ${obj['id']}`);
                }
              //}
              logger(req.headers.call_id, `${key[1]} Updated.\n`);
            }

            logger(req.headers.call_id, `All Updated`);

            status = 'success';
            msg = 'Scene added successfully.';

          } else {
            status = 'failure';
            msg = 'You are not permitted to add scenes.'
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/editScene", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var session;

  try {

    logger(req.headers.call_id, `Edit Scene Started. id: ${body.scene.id}, user: ${body.scene.last_edit_by}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body["scene"]['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body["scene"]["last_edit_by"])) {
          if (project['roles'][body["scene"]["last_edit_by"]]['permissions']['scenes']['edit']) {

            await db.collection('Scenes').updateOne({ id: body['scene'].id, project_id: body.scene.project_id }, { $set: body['scene'] });
            logger(req.headers.call_id, `Scene Edited`);

            var keys = [
              ['artists','Artists','casting'], 
              ['costumes','Costumes','costumes'], 
              ['locations','Locations','locations'], 
              ['props','Props','props'], 
            ];

            for (let ind = 0; ind < keys.length; ind++) {
              const key = keys[ind];
              //if (project['roles'][body["scene"]["last_edit_by"]]['permissions'][key[2]]['edit']) {
                for (let i = 0; i < body[key[0]].length; i++) {
                  const obj = body[key[0]][i];
                  logger(req.headers.call_id, `Updating ${obj['id']}`);
                  await db.collection(key[1]).updateOne({ id: obj['id'], project_id: body.scene.project_id }, {"$set": obj});
                  logger(req.headers.call_id, `Updated ${obj['id']}`);
                }
              //}
              logger(req.headers.call_id, `${key[1]} Updated.\n`);
            }
            logger(req.headers.call_id, `All Updated`);

            status = 'success';
            msg = 'Scene edited successfully.';

          } else {
            status = 'failure';
            msg = 'You are not permitted to edit scenes.'
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/deleteScene", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var session;

  // id, last_edit_by, project_id, 

  try {

    logger(req.headers.call_id, `Delete Scene Started. id: ${body.id}, user: ${body.last_edit_by}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body["last_edit_by"])) {
          if (project['roles'][body["last_edit_by"]]['permissions']['scenes']['edit']) {

            await db.collection('Scenes').deleteOne({ id: body.id, project_id: body.project_id });
            logger(req.headers.call_id, `Scene Deleted`);

            var uns = {}

            uns["costumes."+body.id] = "";
            await db.collection('Artists').updateMany({project_id: body.project_id},{$pull: {"scenes": body.id}, $unset: uns});
            logger(req.headers.call_id, `Artist Updated.`);

            uns = {};
            uns["used_by."+body.id] = "";
            await db.collection('Costumes').updateMany({project_id: body.project_id},{$pull: {"scenes": body.id}, $unset: uns});
            logger(req.headers.call_id, `Costumes Updated.`);

            await db.collection('Props').updateMany({project_id: body.project_id},{$pull: {"used_in": body.id}});
            logger(req.headers.call_id, `Props Updated.`);

            await db.collection('Locations').updateMany({project_id: body.project_id},{$pull: {"used_in": body.id}});
            logger(req.headers.call_id, `Locations Updated.`);

            uns = {};
            uns["addl_timings."+body.id] = "";
            uns["artist_timings."+body.id] = "";
            uns["call_timings."+body.id] = "";
            uns["vfx_timings."+body.id] = "";
            uns["sfx_timings."+body.id] = "";
            await db.collection('Schedules').updateMany({project_id: body.project_id},{$pull: {"scenes": body.id}, $unset: uns});
            logger(req.headers.call_id, `Schedules Updated.`);

            status = 'success';
            msg = 'Scene deleted successfully.';

          } else {
            status = 'failure';
            msg = 'You are not permitted to delete scenes.'
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/editSceneCostumes", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var session;

  try {

    logger(req.headers.call_id, `Edit Scene Costumes Started. id: ${body.id}, user: ${body.last_edit_by}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body["last_edit_by"])) {
          if (project['roles'][body["last_edit_by"]]['permissions']['costumes']['edit']) {

            await db.collection('Scenes').updateOne({ id: body.id, project_id: body.project_id }, { $set: {costumes: body['scene_costumes'], last_edit_on: body.last_edit_on, last_edit_by: body.last_edit_by} });
            logger(req.headers.call_id, `Scene Edited`);

            var keys = [
              ['artists','Artists','artists'], 
              ['costumes','Costumes','costumes'],
            ];

            for (let ind = 0; ind < keys.length; ind++) {
              const key = keys[ind];
                for (let i = 0; i < body[key[0]].length; i++) {
                  const obj = body[key[0]][i];
                  logger(req.headers.call_id, `Updating ${obj['id']}`);
                  await db.collection(key[1]).updateOne({ id: obj['id'], project_id: body.project_id }, {"$set": obj});
                  logger(req.headers.call_id, `Updated ${obj['id']}`);
                }
              logger(req.headers.call_id, `${key[1]} Updated.\n`);
            }

            logger(req.headers.call_id, `All Updated`);

            status = 'success';
            msg = 'Scene Costumes edited successfully.';

          } else {
            status = 'failure';
            msg = 'You are not permitted to edit costumes.'
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/editSceneArtists", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var session;

  try {

    logger(req.headers.call_id, `Edit Scene Artists Started. id: ${body.id}, user: ${body.last_edit_by}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body["last_edit_by"])) {
          if (project['roles'][body["last_edit_by"]]['permissions']['casting']['edit']) {

            await db.collection('Scenes').updateOne({ id: body.id, project_id: body.project_id }, { $set: {costumes: body['scene_costumes'], artists: body['scene_artists'], last_edit_on: body.last_edit_on, last_edit_by: body.last_edit_by} });
            logger(req.headers.call_id, `Scene Edited`);

            var keys = [
              ['artists','Artists','casting'], 
              ['costumes','Costumes','costumes'],
            ];

            for (let ind = 0; ind < keys.length; ind++) {
              const key = keys[ind];
                for (let i = 0; i < body[key[0]].length; i++) {
                  const obj = body[key[0]][i];
                  logger(req.headers.call_id, `Updating ${obj['id']}`);
                  await db.collection(key[1]).updateOne({ id: obj['id'], project_id: body.project_id }, {"$set": obj});
                  logger(req.headers.call_id, `Updated ${obj['id']}`);
                }
              logger(req.headers.call_id, `${key[1]} Updated.\n`);
            }

            logger(req.headers.call_id, `All Updated`);

            status = 'success';
            msg = 'Scene Artists edited successfully.';

          } else {
            status = 'failure';
            msg = 'You are not permitted to edit costumes.'
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/editSceneProps", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var session;

  try {

    logger(req.headers.call_id, `Edit Scene Props Started. id: ${body.id}, user: ${body.last_edit_by}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body["last_edit_by"])) {
          if (project['roles'][body["last_edit_by"]]['permissions']['props']['edit']) {

            await db.collection('Scenes').updateOne({ id: body.id, project_id: body.project_id }, { $set: {props: body['scene_props'], last_edit_on: body.last_edit_on, last_edit_by: body.last_edit_by} });
            logger(req.headers.call_id, `Scene Edited`);

            var keys = [
              ['props','Props','props']
            ];

            for (let ind = 0; ind < keys.length; ind++) {
              const key = keys[ind];
                for (let i = 0; i < body[key[0]].length; i++) {
                  const obj = body[key[0]][i];
                  logger(req.headers.call_id, `Updating ${obj['id']}`);
                  await db.collection(key[1]).updateOne({ id: obj['id'], project_id: body.project_id }, {"$set": obj});
                  logger(req.headers.call_id, `Updated ${obj['id']}`);
                }
              logger(req.headers.call_id, `${key[1]} Updated.\n`);
            }

            logger(req.headers.call_id, `All Updated`);

            status = 'success';
            msg = 'Scene props edited successfully.';

          } else {
            status = 'failure';
            msg = 'You are not permitted to edit costumes.'
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/updateSceneStatus", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var session;

  try {

    logger(req.headers.call_id, `Update Scene Status Started. id: ${body.id}, user: ${body.last_edit_by}, completed: ${body.completed}, completed_on: ${body.completed_on}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body["last_edit_by"])) {
          if (project['roles'][body["last_edit_by"]]['permissions']['schedule']['edit']) {

            await db.collection('Scenes').updateOne({ id: body.id, project_id: body.project_id }, { $set: {completed: body.completed, completed_on: body.completed_on, last_edit_on: body.last_edit_on,last_edit_by: body.last_edit_by} });
            logger(req.headers.call_id, `Scene Status Updated.`);

            status = 'success';
            msg = 'Scene status updated successfully.';

          } else {
            status = 'failure';
            msg = 'You are not permitted to update scenes.'
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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
  var session;

  try {

    logger(req.headers.call_id, `Get Scene Started. id: ${body.id}, project: ${body.project_id}, user: ${body.user_id}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.user_id)) {
            const act = await db.collection('Scenes').findOne({ id: body['id'], project_id: body['project_id'] });
            if (act !== null) {
              status = 'success';
              if (project['roles'][body.user_id]['permissions']['scenes']['view']) {
                scene = act;
              } else {
                var permissions = project['roles'][body.user_id]['permissions'];
                var elements = [
                  ['casting','Artists',['artists', 'addl_artists']], 
                  ['costumes','Costumes',['costumes']], 
                  ['locations','Locations',['location']], 
                  ['props','Props',['props']]];

                var basic_keys = basicKeys['scenes'];

                for(let i = 0;i < elements.length; i++){
                  var e = elements[i];
                  if(permissions[e[0]]['view']){
                    basic_keys = basic_keys.concat(e[2]);
                  }
                }

                basic_keys.forEach((bk) => {
                  scene[bk] = act[bk];
                });
                                 
                logger(req.headers.call_id, `User not permitted.`);
              }
              msg = 'Got Scene successfully.';
            } else {
              status = 'failure';
              msg = 'Scene does not exist.'
              scene = {};
            }
            logger(req.headers.call_id, `${msg}`);
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          scene = {};
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        scene = {};
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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
  var session;

  try {

    logger(req.headers.call_id, `Get Scenes Started. project: ${body.project_id}, user: ${body.user_id}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.user_id)) {
            const datas = await db.collection('Scenes').find({ project_id: body['project_id'] }).toArray();
            datas.sort((a,b) => (a.titles.en > b.titles.en) ? 1 : ((b.titles.en > a.titles.en) ? -1 : 0));
            if (project['roles'][body.user_id]['permissions']['scenes']['view']) {
              datas.forEach(doc => {
                scenes.push(doc);
              });
            } else {
              var permissions = project['roles'][body.user_id]['permissions'];
              var elements = [
                ['casting','Artists',['artists', 'addl_artists']], 
                ['costumes','Costumes',['costumes']], 
                ['locations','Locations',['location']], 
                ['props','Props',['props']]];

              var basic_keys = basicKeys['scenes'];

              for(let i = 0;i < elements.length; i++){
                var e = elements[i];
                if(permissions[e[0]]['view']){
                  basic_keys = basic_keys.concat(e[2]);
                }
              }

              
              datas.forEach((doc) => {
                var d = {};
                basic_keys.forEach((bk) => {
                  d[bk] = doc[bk];
                });
                scenes.push(d);
              });

              logger(req.headers.call_id, `User not permitted.`);
            }
            status = 'success';
            msg = 'Got Scenes successfully.';
            logger(req.headers.call_id, `${msg}`);
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.';
          scenes = [];
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.';
        scenes = [];
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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
  var session;

  try {

    logger(req.headers.call_id, `Add Schedule Started. id: ${body.id}, user: ${body.added_by}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.added_by)) {
          if (project['roles'][body.added_by]['permissions']['schedule']['add']) {
            await db.collection('Schedules').updateOne({ id: body.id, project_id: body.project_id }, { $set: body }, { upsert: true });
            status = 'success';
            msg = 'Schedule added successfully.';
            logger(req.headers.call_id, `${msg}`);
          } else {
            status = 'failure';
            msg = 'You are not permitted to add schedules.'
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/editSchedule", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var session;

  try {

    logger(req.headers.call_id, `Edit Schedule Started. id: ${body.id}, user: ${body.last_edit_by}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.last_edit_by)) {
          if (project['roles'][body.last_edit_by]['permissions']['schedule']['edit']) {
            await db.collection('Schedules').updateOne({ id: body.id, project_id: body.project_id }, { $set: body });
            status = 'success';
            msg = 'Schedule edited successfully.';
            logger(req.headers.call_id, `${msg}`);
          } else {
            status = 'failure';
            msg = 'You are not permitted to edit schedules.'
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/addScheduleName", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var session;

  try {

    logger(req.headers.call_id, `Add Schedule Name. name: ${body.schedule}, project: ${body.project_id}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.added_by)) {
          if (project['roles'][body.added_by]['permissions']['schedule']['add']) {
            await db.collection('projects').updateOne({ id: body['project_id'] }, { "$addToSet": { "schedules": body.schedule } });
            status = 'success';
            msg = 'Schedule Name added successfully.';
            logger(req.headers.call_id, `Schedule Name Added.`);
          } else {
            status = 'failure';
            msg = 'You are not permitted to add schedules.'
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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
  var session;

  try {

    logger(req.headers.call_id, `Get Schedule Started. id: ${body.id}, project: ${body.project_id}, user: ${body.user_id}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.user_id)) {
          if (project['roles'][body.user_id]['permissions']['schedule']['view']) {
            const act = await db.collection('Schedules').findOne({ id: body['id'], project_id: body['project_id'] });
            if (act !== null) {
              status = 'success';
              schedule = act;
              msg = 'Got Schedule successfully.';
            } else {
              status = 'failure';
              msg = 'Schedule does not exist.'
              schedule = {};
            }
            logger(req.headers.call_id, `${msg}`);
          } else {
            status = 'failure';
            msg = 'You are not permitted to view schedules.'
            schedule = {};
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          schedule = {};
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        schedule = {};
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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
  var session;

  try {

    logger(req.headers.call_id, `Get Schedules Started. project: ${body.project_id}, user: ${body.user_id}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.user_id)) {
          if (project['roles'][body.user_id]['permissions']['schedule']['view']) {
            const datas = await db.collection('Schedules').find({ project_id: body['project_id'] }).toArray();
            datas.forEach(doc => {
              schedules.push(doc);
            });
            status = 'success';
            msg = 'Got Schedules successfully.';
            logger(req.headers.call_id, `${msg}`);
          } else {
            status = 'failure';
            msg = 'You are not permitted to view schedules.'
            schedules = [];
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.';
          schedules = [];
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.';
        schedules = [];
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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
  var session;

  try {

    logger(req.headers.call_id, `Add Role Started. id: ${body.id}, user: ${body.added_by}, role_user: ${body.user_id}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.added_by)) {
          if (project['roles'][body.added_by]['permissions']['roles']['add']) {
            var roles = {};
            roles[`roles.${body.user_id}`] = body;
            await db.collection('projects').updateOne({ id: body['project_id'] }, { "$set": roles, "$addToSet": { "roles_ids": body.user_id } });
            logger(req.headers.call_id, `Project Updated.`);
            var te = { "$set": {} };
            te["$set"]["projects." + body['project_id']] = { id: body.project_id, role: body.role, owner: false, accepted: false }
            console.log(te);
            await db.collection('users').updateOne({ id: body['user_id'] }, te);
            logger(req.headers.call_id, `User Updated.`);
            status = 'success';
            msg = 'Role added successfully.';
            logger(req.headers.call_id, `${msg}`);
          } else {
            status = 'failure';
            msg = 'You are not permitted to add roles.'
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/editRole", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var session;

  try {

    logger(req.headers.call_id, `Edit Role Started. id: ${body.id}, user: ${body.last_edit_by}, role_user: ${body.user_id}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.last_edit_by)) {
          if (project['roles'][body.last_edit_by]['permissions']['roles']['edit']) {
            var roles = {};
            roles[`roles.${body.user_id}`] = body;
            await db.collection('projects').updateOne({ id: body['project_id'] }, { "$set": roles });
            logger(req.headers.call_id, `Project Updated.`);
            var te = { "$set": {} };
            te["$set"]["projects." + body['project_id']] = { id: body.project_id, role: body.role, owner: body.owner, accepted: body.accepted }
            console.log(te);
            await db.collection('users').updateOne({ id: body['user_id'] }, te);
            logger(req.headers.call_id, `User Updated.`);
            status = 'success';
            msg = 'Role edited successfully.';
            logger(req.headers.call_id, `${msg}`);
          } else {
            status = 'failure';
            msg = 'You are not permitted to edit roles.'
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/respondRole", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var session;

  try {

    logger(req.headers.call_id, `Respond Role Started. user: ${body.user_id}, project: ${body.project_id}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.user_id)) {
          if (body.accepted) {

            var te = {};
            te["roles." + body.user_id + ".accepted"] = true;
            await db.collection('projects').updateOne({ id: body['project_id'] }, { "$set": te });
            logger(req.headers.call_id, `Project Updated.`);
            te = {};
            te["projects." + body.project_id + ".accepted"] = true;
            await db.collection('users').updateOne({ id: body['user_id'] }, { "$set": te });
            logger(req.headers.call_id, `User Updated.`);

          } else {

            var te = {};
            te["roles." + body.user_id] = "";
            await db.collection('projects').updateOne({ id: body['project_id'] }, { "$unset": te, "$pull": { "roles_ids": body.user_id } });
            logger(req.headers.call_id, `Project Updated.`);
            te = {};
            te["projects." + body.project_id] = "";
            await db.collection('users').updateOne({ id: body['user_id'] }, { "$unset": te });
            logger(req.headers.call_id, `User Updated.`);
          }

          status = 'success';
          msg = 'Role edited successfully.';
          logger(req.headers.call_id, `${msg}`);
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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
  var session;

  try {

    logger(req.headers.call_id, `Add Daily Budget Started. id: ${body.id}, user: ${body.added_by}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.added_by)) {
          if (project['roles'][body.added_by]['permissions']['budget']['add']) {
            await db.collection('DailyBudgets').updateOne({ id: body.id, project_id: body.project_id }, { $set: body }, { upsert: true });
            status = 'success';
            msg = 'DailyBudget added successfully.';
            logger(req.headers.call_id, `${msg}`);
          } else {
            status = 'failure';
            msg = 'You are not permitted to add daily_budgets.'
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'msg': msg,
    'status': status,
  });
});

cinemawala.post("/editDailyBudget", async (req, res) => {
  var body = req.body;
  var msg = '';
  var status = '';
  var session;

  try {

    logger(req.headers.call_id, `Edit Daily Budget Started. id: ${body.id}, user: ${body.last_edit_by}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.last_edit_by)) {
          if (project['roles'][body.last_edit_by]['permissions']['budget']['edit']) {
            await db.collection('DailyBudgets').updateOne({ id: body.id, project_id: body.project_id }, { $set: body });
            status = 'success';
            msg = 'DailyBudget edited successfully.';
            logger(req.headers.call_id, `${msg}`);
          } else {
            status = 'failure';
            msg = 'You are not permitted to edit daily_budgets.'
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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
  var session;

  try {

    logger(req.headers.call_id, `Get Daily Budget Started. id: ${body.id}, project: ${body.project_id}, user: ${body.user_id}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.user_id)) {
          if (project['roles'][body.user_id]['permissions']['budget']['view']) {
            const act = await db.collection('DailyBudgets').findOne({ id: body['id'], project_id: body['project_id'] });
            if (act !== null) {
              status = 'success';
              daily_budget = act;
              msg = 'Got Budget successfully.';
            } else {
              status = 'failure';
              msg = 'Budget does not exist.'
              daily_budget = {};
            }
            logger(req.headers.call_id, `${msg}`);
          } else {
            status = 'failure';
            msg = 'You are not permitted to view budgets.'
            daily_budget = {};
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.'
          daily_budget = {};
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.'
        daily_budget = {};
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

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
  var session;

  try {

    logger(req.headers.call_id, `Get Daily Budgets Started. project: ${body.project_id}, user: ${body.user_id}`);

    session = mongodb.startSession();

    await session.withTransaction(async () => {
      const project = await db.collection('projects').findOne({ id: body['project_id'] });
      if (project !== null) {
        if (project['roles_ids'].includes(body.user_id)) {
          if (project['roles'][body.user_id]['permissions']['budget']['view']) {
            const datas = await db.collection('DailyBudgets').find({ project_id: body['project_id'] }).toArray();
            datas.forEach(doc => {
              daily_budgets.push(doc);
            });
            status = 'success';
            msg = 'Got Daily Budgets successfully.';
            logger(req.headers.call_id, `${msg}`);
          } else {
            status = 'failure';
            msg = 'You are not permitted to view budgets.'
            daily_budgets = [];
            logger(req.headers.call_id, `User not permitted.`);
          }
        } else {
          status = 'failure';
          msg = 'You are not a member of this project.';
          daily_budgets = [];
          logger(req.headers.call_id, `User not a member.`);
        }
      } else {
        status = 'failure';
        msg = 'Project does not exist.';
        daily_budgets = [];
        logger(req.headers.call_id, `${msg}`);
      }
    });
  } catch (e) {
    status = 'failure';
    msg = 'Something went wrong.';
    logger(req.headers.call_id, `${e}`);
  } finally {
    await session.endSession();
    await mongodb.close();
  }

  logger(req.headers.call_id, `end`);

  res.status(200).send({
    'msg': msg,
    'status': status,
    'daily_budgets': daily_budgets
  });
});

cinemawala.get('/', function (req, res) {
  res.send('Cinemwala 1.0.2\n');
});

cinemawala.post("/getCollection", async (req, res) => {
  var r = {};
  r[req.body.collection] = await db.collection(req.body.collection).find({}).toArray();
  res.send(r);
});

cinemawala.post("/createCollection", async (req, res) => {
  await db.createCollection(req.body.name);
  res.send("Done");
});

cinemawala.post("/fillCollection", async (req, res) => {
  try {
    await db.collection(req.body.collection).deleteMany({});
    await db.collection(req.body.collection).insertMany(req.body.docs);
    res.send("Done");
  } catch (e) {
    logger(req.headers.call_id, `${e}`);
    res.send("Error: " + e);
  }
});

cinemawala.post("/appendCollection", async (req, res) => {
  try {
    await db.collection(req.body.collection).insertMany(req.body.docs);
    res.send("Done");
  } catch (e) {
    logger(req.headers.call_id, `${e}`);
    res.send("Error: " + e);
  }
});

cinemawala.listen(2021, () => {
  console.log("Cinemawala listening.")
});