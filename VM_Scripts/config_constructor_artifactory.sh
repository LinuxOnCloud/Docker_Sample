#!/bin/bash

echo "<?xml version='1.0' encoding='UTF-8'?>
<org.jfrog.hudson.ArtifactoryBuilder_-DescriptorImpl plugin="artifactory@2.3.0">
  <artifactoryServers>
    <org.jfrog.hudson.ArtifactoryServer>
      <url>http://$1:8081/artifactory</url>
      <id>-938890871@1429007502699</id>
      <deployerCredentials>
        <username>admin</username>
        <password>cGFzc3dvcmQ=</password>
      </deployerCredentials>
      <timeout>300</timeout>
      <bypassProxy>false</bypassProxy>
    </org.jfrog.hudson.ArtifactoryServer>
  </artifactoryServers>
</org.jfrog.hudson.ArtifactoryBuilder_-DescriptorImpl>" > /root/.jenkins/org.jfrog.hudson.ArtifactoryBuilder.xml
