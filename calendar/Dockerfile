FROM google/cloud-sdk

RUN apt-get update -y && \
    apt-get install -y python3-distutils

RUN python3.7 -m pip install \
	fire==0.3.1 \
	google-api-python-client==1.12.4 \
	google-auth-oauthlib==0.4.1 \
	oauth2client==4.1.3 \	
	python-dateutil==2.8.1 \
	pyyaml==5.3.1 \
	six==1.15.0

RUN mkdir -p /opt/kubeflow
COPY calendar_import.py /opt/kubeflow
