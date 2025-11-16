FROM dart:stable

WORKDIR /app

# Copy server pubspec files and get dependencies first
COPY server/pubspec.* ./
RUN dart pub get

# Copy only the server source
COPY server/. .

# Expose the port used by the server (defaults to 8080)
EXPOSE 8080

# Run the Dart server
CMD ["dart", "run", "bin/server.dart"]
