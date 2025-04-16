FROM node:18-alpine

WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./
RUN npm install --production

COPY . .

# Expose the app port
EXPOSE 8080

# Start the app
CMD ["node", "server.js"]