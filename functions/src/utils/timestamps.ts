import { FieldValue } from "../config/firebase";

/** Standard createdAt/updatedAt pair for new documents. */
export function withCreateTimestamps<T extends object>(data: T) {
  return {
    ...data,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };
}

/** Standard updatedAt bump for existing documents. */
export function withUpdateTimestamp<T extends object>(data: T) {
  return {
    ...data,
    updatedAt: FieldValue.serverTimestamp(),
  };
}
