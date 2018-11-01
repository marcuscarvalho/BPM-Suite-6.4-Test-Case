FROM openjdk:8
VOLUME /tmp
EXPOSE 9999 9990 8080 8787 8001 9418
ENV JBOSS_USER=jbossAdmin JBOSS_PASS=redhat99 BPMS_USER=kieserver BPMS_PASS=kieserver1!
COPY *.zip *.cli /tmp/
WORKDIR /tmp
RUN unzip -q /tmp/jboss-eap-7.0.0.zip -d /opt && \
    ln -s /opt/jboss-eap-7.0 /opt/jboss-eap && \
    /opt/jboss-eap/bin/jboss-cli.sh --command="patch apply /tmp/jboss-eap-7.0.9-patch.zip" && \
    unzip -o -q /tmp/jboss-bpmsuite-6.4.0.GA-deployable-eap7.x.zip -d /opt && \
    unzip -q /tmp/jboss-bpmsuite-6.4.11-patch.zip -d /opt && \
    cd /opt/jboss-bpmsuite-6.4.11-patch && \
    /opt/jboss-bpmsuite-6.4.11-patch/apply-updates.sh /opt/jboss-eap-7.0 eap7.x && \
    /opt/jboss-eap/bin/add-user.sh -u $JBOSS_USER -p $JBOSS_PASS && \
    /opt/jboss-eap/bin/add-user.sh -a $BPMS_USER -p $BPMS_PASS -g "admin,kie-server,rest-all" && \
    /opt/jboss-eap/bin/add-user.sh -a controllerUser -p "controllerUser1234;" -g "kie-server,rest-all" && \
    /opt/jboss-eap/bin/jboss-cli.sh --file=/tmp/config.cli && \
    rm -rf /opt/jboss-eap/standalone/configuration/standalone_xml_history/current

CMD /opt/jboss-eap/bin/standalone.sh -Djboss.bind.address.management=0.0.0.0 -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.unsecure=0.0.0.0 --debug
