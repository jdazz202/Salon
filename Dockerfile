# Use the official NGINX image
FROM nginx:alpine

# Remove the default NGINX static content
RUN rm -rf /usr/share/nginx/html/*

# Copy your static site (HTML, CSS, JS, etc.) into the container
COPY . /usr/share/nginx/html

# Expose port 80 for web traffic
EXPOSE 80

# Start NGINX in the foreground
CMD ["nginx", "-g", "daemon off;"]
