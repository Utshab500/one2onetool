# BUILD STAGE
FROM node:18.7-alpine AS build

COPY . /var/app

WORKDIR /var/app

RUN pwd \
    && ls -l \
    && npm ci \
    && npm test


# RUNTIME STAGE
FROM gcr.io/distroless/nodejs:18

COPY --from=build /var/app/node_modules /var/app/node_modules
COPY --from=build /var/app/controllers /var/app/controllers
COPY --from=build /var/app/data /var/app/data
COPY --from=build /var/app/helpers /var/app/helpers
COPY --from=build /var/app/models /var/app/models
COPY --from=build /var/app/routes /var/app/routes
COPY --from=build /var/app/views /var/app/views
COPY --from=build /var/app/index.js /var/app/index.js


WORKDIR /var/app

EXPOSE 3000
CMD [ "index.js" ]
