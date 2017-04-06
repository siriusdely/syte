FROM python:2.7
MAINTAINER Sirius Dely
ENV PYTHONUNBUFFERED 1
RUN mkdir /code
RUN mkdir /code/logs
WORKDIR /code
COPY requirements.txt /code/
RUN pip install -r requirements.txt
ADD . /code/
COPY start.sh /code/start.sh
EXPOSE 8008
CMD ["/code/start.sh"]
