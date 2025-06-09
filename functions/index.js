/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const functions = require("firebase-functions");
const express = require("express");
const cors = require("cors");
const admin = require("firebase-admin");

admin.initializeApp();

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

// 인증 미들웨어
const authenticateUser = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith("Bearer ")) {
      return res.status(401).json({ error: "인증 토큰이 필요합니다." });
    }

    const token = authHeader.split("Bearer ")[1];
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    res.status(401).json({ error: "인증에 실패했습니다." });
  }
};

// 테스트 엔드포인트 추가
app.get("/stay/test", (req, res) => {
  res.status(200).json({ message: "연결 성공!" });
});

// Stay Request Routes
app.post("/stay/submit", authenticateUser, async (req, res) => {
  try {
    const { date, reason, requestTime } = req.body;
    const userId = req.user.uid;

    const stayRequest = {
      userId,
      date: new Date(date),
      reason,
      requestTime: new Date(requestTime),
      status: "pending",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    const docRef = await admin
      .firestore()
      .collection("stayRequests")
      .add(stayRequest);

    res.status(201).json({
      id: docRef.id,
      ...stayRequest,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.api = functions.https.onRequest(app);
