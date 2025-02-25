# Use official Python runtime as base image
FROM python:3.9.21

# Set working directory in container
WORKDIR /app

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code into container
COPY ./app/ .

# Expose port 5000
EXPOSE 5000

# Run the application
CMD ["uwsgi", "--ini", "app.ini"]
