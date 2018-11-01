# Docker JBoss BPMS

Before start
------------
Download files below into project's root directory

* [jboss-eap-7.0.0.zip](https://access.redhat.com/jbossnetwork/restricted/softwareDownload.html?softwareId=43891)
* [jboss-eap-7.0.9-patch.zip](https://access.redhat.com/jbossnetwork/restricted/softwareDownload.html?softwareId=55651)
* [jboss-bpmsuite-6.4.0.GA-deployable-eap7.x.zip](https://access.redhat.com/jbossnetwork/restricted/softwareDownload.html?softwareId=48441)
* [jboss-bpmsuite-6.4.11-patch.zip](https://access.redhat.com/jbossnetwork/restricted/softwareDownload.html?softwareId=60561)

Start
-----
Open terminal in docker-compose.yml directory and run command below.

```bash
$ docker-compose up --build
```

JBoss BPMS
----------
Browse to http://localhost:8080/business-central[http://localhost:8080/business-central]

User: kieserver
Pass: kieserver1!

Config section
---------------------------------
HOST=localhost
PORT=8080
 
KIE_USER=kieserver
KIE_PWD=kieserver1!
 
PROJECT_GROUP=com.sample
PROJECT_ARTIFACT=SampleProcess
PROJECT_ID=1.0.0
 
PROCESS_NAME=SampleProcess.SampleBusinessRuleProcess
RUNTIME_STRATEGY=PER_PROCESS_INSTANCE
 
KIE_CRED=$KIE_USER:$KIE_PWD
PROJECT_GAV=$PROJECT_GROUP:$PROJECT_ARTIFACT:$PROJECT_ID
 
Build the project
-----------------
(cd repository1Test/SampleProcess/ && mvn clean install)
 
Delete container
----------------
curl -v -X DELETE -u ${KIE_CRED} http://${HOST}:${PORT}/kie-server/services/rest/server/containers/${PROJECT_GAV}
 
Create container template
-------------------------
echo '<script>' > create-container.xml
echo '  <create-container>' >> create-container.xml
echo '    <container container-id="'${PROJECT_GAV}'">' >> create-container.xml
echo '      <release-id>' >> create-container.xml
echo '        <group-id>'${PROJECT_GROUP}'</group-id>' >> create-container.xml
echo '        <artifact-id>'${PROJECT_ARTIFACT}'</artifact-id>' >> create-container.xml
echo '        <version>'${PROJECT_ID}'</version>' >> create-container.xml
echo '      </release-id>' >> create-container.xml
echo '      <config-items>' >> create-container.xml
echo '        <itemName>RuntimeStrategy</itemName>' >> create-container.xml
echo '        <itemValue>'${RUNTIME_STRATEGY}'</itemValue>' >> create-container.xml
echo '        <itemType></itemType>' >> create-container.xml
echo '      </config-items>' >> create-container.xml
echo '    </container>' >> create-container.xml
echo '  </create-container>' >> create-container.xml
echo '</script>' >> create-container.xml
 
Create container
----------------
curl -v -X POST -H 'Content-type: application/xml' -H 'X-KIE-Content-Type: xstream' -d @create-container.xml -u ${KIE_CRED} http://${HOST}:${PORT}/kie-server/services/rest/server/config/
 
# WORKING
#{\"pProductType\":\"SJC\", \"pPriority\":\"NORM\", \"pItemLocation\":\"SJC1\", \"pNotificationStatus\":\"ACPT\", \"pReturnToSenderState\":\"false\", \"pOriginalMOIBranchID\":\"SJC1\", \"pDestination\":\"B1\", \"pZoneID\":\"6\", \"pDeliveryPreference\":\"Address\", \"pDestinationCountry\":\"QA\"}
PROCID=`curl -s -X POST -H 'Content-type: application/json' -H 'X-KIE-Content-Type: json' -d "{\"pProductType\":\"SJC\", \"pPriority\":\"NORM\", \"pItemLocation\":\"SJC1\", \"pNotificationStatus\":\"ACPT\", \"pReturnToSenderState\":\"false\", \"pOriginalMOIBranchID\":\"SJC1\", \"pDestination\":\"B1\", \"pZoneID\":\"6\", \"pDeliveryPreference\":\"Address\", \"pDestinationCountry\":\"QA\"}" -u ${KIE_CRED} http://${HOST}:${PORT}/kie-server/services/rest/server/containers/${PROJECT_GAV}/processes/${PROCESS_NAME}/instances` && echo Process ${PROCID} created for process ${PROCESS_NAME}
 
# NON WORKING
PROCID=`curl -s -X POST -H 'Content-type: application/json' -H 'X-KIE-Content-Type: json' -d "{\"pProductType\":\"SJC\", \"pPriority\":\"NORM\", \"pItemLocation\":\"B1\", \"pNotificationStatus\":\"ACPT\", \"pReturnToSenderState\":\"false\", \"pOriginalMOIBranchID\":\"SJC1\", \"pDestination\":{\"buildingNo\":\"0\", \"postalCode\":\"0\", \"streetNumber\":\"0\", \"zone\":\"6\"}, \"pZoneID\":\"6\", \"pDeliveryPreference\":\"Address\", \"pDestinationCountry\":\"QA\"}" -u ${KIE_CRED} http://${HOST}:${PORT}/kie-server/services/rest/server/containers/${PROJECT_GAV}/processes/${PROCESS_NAME}/instances` && echo Process ${PROCID} created for process ${PROCESS_NAME}
