# Use a lightweight Node.js image
FROM node:20.2-bullseye-slim

# Install Angular CLI globally
RUN npm install -g @angular/cli

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json first (for caching layers)
COPY /app .

# Install dependencies
RUN npm install

# Expose the development server port
EXPOSE 4201

# Serve the Angular application
CMD ["ng", "serve", "--configuration", "production", "--open", "--host", "0.0.0.0", "--port", "4201", "--disable-host-check"]
