# Builder stage: install all dependencies and compile TypeScript.
FROM node:26-alpine AS dev

WORKDIR /app

# Install dependencies as a separate step to take advantage of Docker's
# caching. Leverage a cache mount to /root/.npm to speed up subsequent
# builds. Leverage a bind mount to package.json to avoid having to copy
# it into this layer.
# RUN --mount=type=cache,target=/root/.npm \
#     --mount=type=bind,source=package.json,target=package.json \
#     npm install
# Once you create a package-lock.json by running npm install locally, switch to npm ci and bind both files:
RUN --mount=type=cache,target=/root/.npm \
    --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    npm ci

# Copy the source code into the container and compile TypeScript.
COPY . .

RUN npm run build

# Deps stage: install production dependencies only.
FROM node:26-alpine AS deps

WORKDIR /app

# RUN --mount=type=cache,target=/root/.npm \
#     --mount=type=bind,source=package.json,target=package.json \
#     npm install --omit=dev
# Once you create a package-lock.json by running npm install locally, switch to npm ci and bind both files:
RUN --mount=type=cache,target=/root/.npm \
    --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    npm ci --omit=dev

# Runner stage: minimal runtime image with compiled app and production deps.
FROM node:26-alpine AS runner

WORKDIR /app
ENV NODE_ENV=production
ENV PATH=/app/node_modules/.bin:$PATH

COPY --from=deps --chown=node:node /app/node_modules ./node_modules
COPY --from=dev --chown=node:node /app/dist ./dist
COPY --from=dev --chown=node:node /app/docs ./docs

# Expose the port that the application listens on.
EXPOSE 3000
USER node
# Run the application.
CMD ["node", "dist/server.js"]