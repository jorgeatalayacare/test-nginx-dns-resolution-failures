# Use the official NGINX image as the base image
FROM nginx

# Copy the default NGINX configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Define the command to start NGINX, using the custom configuration file if provided
CMD ["nginx", "-g", "daemon off;"]
