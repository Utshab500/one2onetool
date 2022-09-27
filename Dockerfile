# BUILD STAGE
FROM node:18.7-alpine AS build

COPY . /var/app

WORKDIR /var/app

RUN pwd \
    && ls -l \
    && npm ci \
    && npm test


# RUNTIME STAGE
FROM node:18.7-alpine

COPY --chown=node --from=build /var/app/node_modules /var/app/node_modules
COPY --chown=node --from=build /var/app/controllers /var/app/controllers
COPY --chown=node --from=build /var/app/data /var/app/data
COPY --chown=node --from=build /var/app/helpers /var/app/helpers
COPY --chown=node --from=build /var/app/models /var/app/models
COPY --chown=node --from=build /var/app/routes /var/app/routes
COPY --chown=node --from=build /var/app/views /var/app/views
COPY --chown=node --from=build /var/app/index.js /var/app/index.js


USER node
WORKDIR /var/app

RUN pwd \
    && ls -l

EXPOSE 3000
ENTRYPOINT [ "node_modules/forever/bin/forever", "-w", "index.js" ]
