# Stage 1: Build the application
# Use a Node.js image with build tools
FROM node:20-alpine AS build

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json to leverage Docker layer caching
COPY package*.json ./

# Install dependencies, including dev dependencies for the build
RUN npm install

# Copy the rest of the application source code
COPY . .

# Build the application
RUN npm run build

# Stage 2: Create the final, lightweight production image
# Use a minimal Node.js image for the runtime
FROM node:20-alpine AS production

# Set the working directory
WORKDIR /app

# Copy only the necessary files from the build stage
# This includes the built application and production dependencies
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./package.json

# Expose the application port
EXPOSE 3000

# Run the application
CMD ["node", "dist/server.js"]

