# Use Dart official image
FROM dart:stable

# Set working directory
WORKDIR /app

# Copy pubspec files and get dependencies first
COPY pubspec.* ./
RUN dart pub get

# Copy all project files
COPY . .

# Expose the port your Dart server will run on
EXPOSE 8080

# Run the Dart server
CMD ["dart", "run", "server/bin/server.dart"]
