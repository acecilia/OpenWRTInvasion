FROM docker.io/library/python:3-alpine

WORKDIR /app

COPY requirements.txt ./

RUN pip install -r requirements.txt

COPY . ./

CMD [ "python", "remote_command_execution_vulnerability.py" ]
