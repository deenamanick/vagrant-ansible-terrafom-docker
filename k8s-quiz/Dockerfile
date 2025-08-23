FROM python:3.11-slim

# Prevent Python from writing .pyc files & enable stdout/stderr output
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Copy all files
COPY . /app/
COPY requirements.txt .

# Install Flask
RUN pip install --no-cache-dir -r requirements.txt

# Expose the app port
EXPOSE 8080

# Flask environment variables
ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=8080

# Use flask run to start the app
CMD ["flask", "run"]
