# ubuntu
FROM node:20.2-bullseye-slim	

RUN npm install -g @angular/cli

WORKDIR /app
COPY package.json .
COPY package-lock.json .

RUN npm install

EXPOSE 4200

COPY . .

CMD /app/node_modules/.bin/ng serve --configuration production --open --host 0.0.0.0 --port 4200 --disable-host-check




