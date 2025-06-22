const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails
} = require('@firebase/rules-unit-testing');
const fs = require('fs');

describe('Firestore security rules', function() {
    this.timeout(10000);
    let testEnv;

  before(async () => {
    testEnv = await initializeTestEnvironment({
      projectId: "demo-project",
      firestore: {
        rules: fs.readFileSync("firestore.rules", "utf8")
      }
    });
  });

  after(async () => {
    await testEnv.cleanup();
  });

  it("allows user A to read their own journal", async () => {
    const alice = testEnv.authenticatedContext('aliceUID');
    await testEnv.withSecurityRulesDisabled(async adminCtx => {
    await adminCtx.firestore()
        .doc('users/aliceUID/journal/entry1')
        .set({ text: "hi", timestamp: Date.now(), label: "foo" });
    });

    // Apoi verificăm cu contextul utilizatorului
    const aliceDb = testEnv.authenticatedContext('aliceUID').firestore();
    await assertSucceeds(
      aliceDb.doc('users/aliceUID/journal/entry1').get()
    );
  });

  it("denies user B from reading user A's journal", async () => {
    const bob = testEnv.authenticatedContext('bobUID');
    await assertFails(
      bob.firestore().doc('users/aliceUID/journal/entry1').get()
    );
  });

  it("permite user-ului A să scrie și să citească propriile măsurători", async () => {
    const aliceAdmin = testEnv.unauthenticatedContext().firestore(); 
    // scriem ca admin, să nu fie restricționat de reguli
    await testEnv.withSecurityRulesDisabled(async adminCtx => {
      await adminCtx.firestore()
        .doc('users/aliceUID/measurements/m1')
        .set({ value: 123, timestamp: Date.now() });
      await adminCtx.firestore()
        .doc('users/aliceUID/water/2025-06-22')
        .set({ amount: 2, timestamp: Date.now() });
      await adminCtx.firestore()
        .doc('users/aliceUID/sleep/2025-06-21')
        .set({ hours: 7, timestamp: Date.now() });
    });

    // acum citim cu contextul lui Alice
    const alice = testEnv.authenticatedContext('aliceUID').firestore();
    await assertSucceeds(
      alice.doc('users/aliceUID/measurements/m1').get()
    );
    await assertSucceeds(
      alice.doc('users/aliceUID/water/2025-06-22').get()
    );
    await assertSucceeds(
      alice.doc('users/aliceUID/sleep/2025-06-21').get()
    );
  });

  it("blochează user-ul B să citească datele lui A", async () => {
    const bob = testEnv.authenticatedContext('bobUID').firestore();
    await assertFails(
      bob.doc('users/aliceUID/measurements/m1').get()
    );
    await assertFails(
      bob.doc('users/aliceUID/water/2025-06-22').get()
    );
    await assertFails(
      bob.doc('users/aliceUID/sleep/2025-06-21').get()
    );
  });
});
