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
# Set environment variables
ENV FLASK_APP=app.py
ENV FLASK_ENV=production
ENV SQLALCHEMY_DATABASE_URI=mysql+pymysql://user:password@db/shopping_list

# Expose port 5000
EXPOSE 5000

# Run the application
CMD ["uwsgi", "--ini", "app.ini"]
