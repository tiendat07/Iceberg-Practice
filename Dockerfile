FROM pyspark as spark-iceberg

# Download iceberg spark runtime
RUN curl https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.3_2.12/1.1.0/iceberg-spark-runtime-3.3_2.12-1.1.0.jar -Lo /opt/spark/jars/iceberg-spark-runtime-3.3_2.12-1.1.0.jar

ENV TABULAR_VERSION=0.50.4

RUN curl https://tabular-repository-public.s3.amazonaws.com/releases/io/tabular/tabular-client-runtime/${TABULAR_VERSION}/tabular-client-runtime-${TABULAR_VERSION}.jar -Lo /opt/spark/jars/tabular-client-runtime-${TABULAR_VERSION}.jar

# Download Java AWS SDK
RUN curl https://repo1.maven.org/maven2/software/amazon/awssdk/bundle/2.17.257/bundle-2.17.257.jar -Lo /opt/spark/jars/bundle-2.17.257.jar

# Download URL connection client required for S3FileIO
RUN curl https://repo1.maven.org/maven2/software/amazon/awssdk/url-connection-client/2.17.257/url-connection-client-2.17.257.jar -Lo /opt/spark/jars/url-connection-client-2.17.257.jar

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
 && unzip awscliv2.zip \
 && sudo ./aws/install \
 && rm awscliv2.zip \
 && rm -rf aws/

# Add iceberg spark runtime jar to IJava classpath
ENV IJAVA_CLASSPATH=/opt/spark/jars/*

RUN mkdir -p /home/iceberg/localwarehouse /home/iceberg/notebooks /home/iceberg/warehouse /home/iceberg/spark-events /home/iceberg

ARG jupyterlab_version=3.6.1

RUN apt-get update -y && \
    apt-get install -y python3-pip python3-dev && \
    pip3 install --upgrade pip && \
    pip3 install wget jupyterlab==${jupyterlab_version}

# Add a notebook command
RUN echo '#! /bin/sh' >> /bin/notebook \
 && echo 'export PYSPARK_DRIVER_PYTHON=jupyter' >> /bin/notebook \
 && echo "export PYSPARK_DRIVER_PYTHON_OPTS=\"lab --notebook-dir=/home/iceberg/notebooks --ip='0.0.0.0' --NotebookApp.token='' --port=8888 --no-browser --allow-root\"" >> /bin/notebook \
 && echo 'pyspark' >> /bin/notebook \
 && chmod u+x /bin/notebook


ENTRYPOINT ["./entrypoint.sh"]
CMD ["notebook"]