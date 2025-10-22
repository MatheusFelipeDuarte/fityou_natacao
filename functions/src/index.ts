import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

/**
 * Callable: setUserRoles
 * Payload: { email: string, password?: string, roles: string[] }
 * Behavior: creates/updates user in Auth, sets custom claims, ensures users/{uid} doc with email+roles
 * Returns: { uid, email, roles }
 */
export const setUserRoles = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required');
  }
  const caller = context.auth.token as any;
  const callerRoles: string[] = Array.isArray(caller.roles) ? caller.roles : [];
  if (!(caller.admin === true || callerRoles.includes('admin'))) {
    throw new functions.https.HttpsError('permission-denied', 'Admin only');
  }

  const email = (data?.email || '').toString().trim().toLowerCase();
  const password: string | undefined = data?.password ? String(data.password) : undefined;
  const roles: string[] = Array.isArray(data?.roles) ? data.roles.map((r: any) => String(r)) : [];
  if (!email) throw new functions.https.HttpsError('invalid-argument', 'email is required');

  // Find or create user
  let user: admin.auth.UserRecord;
  try {
    user = await admin.auth().getUserByEmail(email);
    if (password) {
      await admin.auth().updateUser(user.uid, { password });
    }
  } catch (e: any) {
    if (e?.errorInfo?.code === 'auth/user-not-found') {
      user = await admin.auth().createUser({ email, password: password ?? Math.random().toString(36).slice(2, 12) });
    } else {
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
export const deleteUser = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required');
  }
  const caller = context.auth.token as any;
  const callerUid = context.auth.uid;
  const callerRoles: string[] = Array.isArray(caller.roles) ? caller.roles : [];
  const isAdmin = (caller.admin === true || callerRoles.includes('admin'));

  const uid = (data?.uid || '').toString().trim();
  const email = (data?.email || '').toString().trim().toLowerCase();
  let targetUid = uid;

  if (!targetUid) {
    if (!email) throw new functions.https.HttpsError('invalid-argument', 'uid or email is required');
    const user = await admin.auth().getUserByEmail(email);
    targetUid = user.uid;
  }

  // Permission: admin can delete anyone; non-admin can delete only themselves
  if (!isAdmin && callerUid !== targetUid) {
    throw new functions.https.HttpsError('permission-denied', 'Not allowed');
  }

  await admin.auth().deleteUser(targetUid);
  // Delete Firestore docs keyed by uid and legacy email id
  const tasks: Promise<any>[] = [];
  tasks.push(db.collection('users').doc(targetUid).delete().catch(() => {}));
  if (email) tasks.push(db.collection('users').doc(email).delete().catch(() => {}));
  await Promise.all(tasks);
  return { uid: targetUid, deleted: true };
});
