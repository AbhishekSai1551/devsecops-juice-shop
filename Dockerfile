# Dependencies installer (heavier image)
FROM node:20-alpine AS installer
#Install dependecies for npm install
RUN apk add --no-cache git python3 make g++

WORKDIR /juice-shop
#Copy all application code to the work directory
COPY . .
#Install production dependencies
RUN npm install --production --unsafe-perm && \
npm dedupe && \
rm -rf frontend/node_modules

#Lighter image to run the app

FROM node:20-alpine

WORKDIR /juice-shop
#Add new group juicer and user in the group juicer
RUN addgroup -S juicer && adduser -S -G juicer juicer
# Copy built application from installer and the user owns the files
COPY --from=installer --chown=juicer:juicer /juice-shop .

RUN mkdir logs && \
    chown -R juicer logs && \
    chgrp -R 0 ftp/ frontend/dist/ logs/ data/ i18n/ && \
    chmod -R g=u ftp/ frontend/dist/ logs/ data/ i18n/

USER juicer

EXPOSE 3000

CMD [ "npm", "start" ]
