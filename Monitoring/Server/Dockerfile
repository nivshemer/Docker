# For more information, please refer to https://aka.ms/vscode-docker-python
FROM python:3.8-slim

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

# Install pip requirements
# Install pip3 requirements
# Install pip4 requirements
COPY requirements.txt .
RUN python -m pip install -r requirements.txt
# RUN apk add python-dev libpq-dev
# RUN sudo apt-get install libpq-dev python-dev

WORKDIR /app
COPY . /app

EXPOSE 8080
EXPOSE 2375

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-python-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app

#RUN apt remove curl
RUN apt-get update && apt-get install -y \
curl
RUN curl -fsSL https://get.docker.com -o get-docker.sh
RUN sh get-docker.sh

USER appuser

# During debugging, this entry point will be overridden. For more information, please refer to https://aka.ms/vscode-docker-python-debug
CMD ["python", "main.py"]
