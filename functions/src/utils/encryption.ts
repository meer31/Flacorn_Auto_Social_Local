import CryptoJS from "crypto-js";
import { env } from "../config/env";

/**
 * AES-256 encryption helpers for OAuth access/refresh tokens at rest.
 *
 * PDF Section 10 requirement: "Tokens must be encrypted before saving.
 * Tokens must never be visible in Flutter."
 *
 * These functions are used exclusively inside Cloud Functions
 * (social-oauth/*, scheduling/runScheduledPosts.ts). Never import this
 * module from any client-facing code.
 */

export function encryptToken(plainText: string): string {
  if (!env.tokenEncryptionKey) {
    throw new Error("TOKEN_ENCRYPTION_KEY is not configured.");
  }
  return CryptoJS.AES.encrypt(plainText, env.tokenEncryptionKey).toString();
}

export function decryptToken(cipherText: string): string {
  if (!env.tokenEncryptionKey) {
    throw new Error("TOKEN_ENCRYPTION_KEY is not configured.");
  }
  const bytes = CryptoJS.AES.decrypt(cipherText, env.tokenEncryptionKey);
  return bytes.toString(CryptoJS.enc.Utf8);
}
