FROM ubuntu:22.04
LABEL authors="rylan"
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y git curl wget software-properties-common jq \
    libjpeg-dev zlib1g-dev libfreetype6-dev liblcms2-dev libopenjp2-7 libtiff5 libwebp-dev tcl-dev tk-dev \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt update \
    && apt install -y python3.12 python3.12-distutils python3.12-venv python3.12-dev \
    && python3.12 -m venv venv
RUN bash -c "source venv/bin/activate \
    && pip3 install uv \
    && uv pip install pipenv setuptools wheel"

RUN mkdir /app
COPY Prusa-Firmware-Buddy/ /app/Prusa-Firmware-Buddy

WORKDIR /app

CMD ["bash"]