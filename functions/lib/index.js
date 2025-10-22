"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteUser = exports.setUserRoles = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();
/**
 * Callable: setUserRoles
 * Payload: { email: string, password?: string, roles: string[] }
 * Behavior: creates/updates user in Auth, sets custom claims, ensures users/{uid} doc with email+roles
 * Returns: { uid, email, roles }
 */
exports.setUserRoles = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'Authentication required');
    }
    const caller = context.auth.token;
    const callerRoles = Array.isArray(caller.roles) ? caller.roles : [];
    if (!(caller.admin === true || callerRoles.includes('admin'))) {
        throw new functions.https.HttpsError('permission-denied', 'Admin only');
    }
    const email = (data?.email || '').toString().trim().toLowerCase();
    const password = data?.password ? String(data.password) : undefined;
    const roles = Array.isArray(data?.roles) ? data.roles.map((r) => String(r)) : [];
    if (!email)
        throw new functions.https.HttpsError('invalid-argument', 'email is required');
    // Find or create user
    let user;
    try {
        user = await admin.auth().getUserByEmail(email);
        if (password) {
            await admin.auth().updateUser(user.uid, { password });
        }
    }
    catch (e) {
        if (e?.errorInfo?.code === 'auth/user-not-found') {
            user = await admin.auth().createUser({ email, password: password ?? Math.random().toString(36).slice(2, 12) });
        }
        else {
            throw new functions.https.HttpsError('internal', e?.message || 'Auth error');
        }
    }
    // Set custom claims with roles array
    await admin.auth().setCustomUserClaims(user.uid, { roles: roles });
    // Mirror to Firestore users/{uid}
    await db.collection('users').doc(user.uid).set({ email, roles }, { merge: true });
    return { uid: user.uid, email, roles };
});
/**
 * Callable: deleteUser
 * Payload: { uid?: string, email?: string }
 * Behavior: deletes user from Auth and removes users/{uid} document
 */
exports.deleteUser = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'Authentication required');
    }
    const caller = context.auth.token;
    const callerRoles = Array.isArray(caller.roles) ? caller.roles : [];
    if (!(caller.admin === true || callerRoles.includes('admin'))) {
        throw new functions.https.HttpsError('permission-denied', 'Admin only');
    }
    const uid = (data?.uid || '').toString().trim();
    const email = (data?.email || '').toString().trim().toLowerCase();
    let targetUid = uid;
    if (!targetUid) {
        if (!email)
            throw new functions.https.HttpsError('invalid-argument', 'uid or email is required');
        const user = await admin.auth().getUserByEmail(email);
        targetUid = user.uid;
    }
    await admin.auth().deleteUser(targetUid);
    // Delete Firestore docs keyed by uid and legacy email id
    const tasks = [];
    tasks.push(db.collection('users').doc(targetUid).delete().catch(() => { }));
    if (email)
        tasks.push(db.collection('users').doc(email).delete().catch(() => { }));
    await Promise.all(tasks);
    return { uid: targetUid, deleted: true };
});
//# sourceMappingURL=index.js.map