/**
 * Environment configuration object
 */
export const config = {
  tmdb: {
    apiKey: process.env.TMDB_API_KEY || "",
  },
  server: {
    port: parseInt(process.env.PORT || "0"),
  },
};

/**
 * Validates that required environment variables are set
 */
export function validateConfig(): void {
  const errors: string[] = [];

  if (!config.tmdb.apiKey) {
    errors.push("TMDB_API_KEY is not set in environment variables");
  }

  if (!config.server.port) {
    errors.push("PORT is not set in environment variables");
  }

  if (errors.length > 0) {
    throw new Error(
      `Configuration validation failed:\n${errors.map((e) => `  - ${e}`).join("\n")}`,
    );
  }
}
