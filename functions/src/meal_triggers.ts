import * as admin from "firebase-admin";
import {onDocumentWritten} from "firebase-functions/v2/firestore";

export const onMealEntryChanged = onDocumentWritten(
  "users/{uid}/meal_entries/{entryId}",
  async (event) => {
    const uid = event.params.uid;
    if (!uid) return;

    const mealsRef = admin
      .firestore()
      .collection("users")
      .doc(uid)
      .collection("meal_entries");

    const mealsSnap = await mealsRef.get();

    const mealCount = mealsSnap.size;
    let lastMealDate: string | null = null;

    if (!mealsSnap.empty) {
      const dates = mealsSnap.docs
        .map((d) => d.data().date as string | undefined)
        .filter((d): d is string => typeof d === "string" && d.length > 0);

      if (dates.length > 0) {
        dates.sort().reverse();
        lastMealDate = dates[0];
      }
    }

    const update: Record<string, unknown> = {mealCount};

    if (lastMealDate) {
      update.lastMealDate = lastMealDate;
    } else {
      update.lastMealDate = admin.firestore.FieldValue.delete();
    }

    await admin
      .firestore()
      .collection("users")
      .doc(uid)
      .update(update);
  }
);
