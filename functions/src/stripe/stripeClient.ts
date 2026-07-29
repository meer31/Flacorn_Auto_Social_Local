import Stripe from "stripe";
import { env } from "../config/env";

/**
 * Single Stripe SDK instance. Never instantiate `new Stripe(...)` anywhere
 * else in the codebase — import `stripe` from here.
 */
export const stripe = new Stripe(env.stripe.secretKey || "sk_test_placeholder", {
  apiVersion: "2024-06-20",
  typescript: true,
});
