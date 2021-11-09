FROM python:3

WORKDIR /app

COPY requirements.txt requirements.txt

COPY scripts/*.sh ./

RUN pip install -r requirements.txt

COPY scripts/ ./

RUN chmod u+x run_py.sh

CMD ["sh", "run_py.sh"]
