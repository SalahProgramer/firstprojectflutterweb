FROM dart:stable-sdk as build
WORKDIR /app
COPY server/pubspec.* ./
RUN dart pub get
COPY server/. .
RUN dart compile exe bin/server.dart -o bin/server

FROM debian:stable-slim
WORKDIR /app
COPY --from=build /app/bin/server .
EXPOSE 8080
CMD ["./server"]
