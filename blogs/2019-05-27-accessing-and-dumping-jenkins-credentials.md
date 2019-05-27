---
title: "Accessing and dumping Jenkins credentials"
date: "2019-05-27"
---

# Accessing and dumping Jenkins credentials

Creating, accessing and dumping Jenkins credentials.

![Banner](./images/2019-05-27-accessing-and-dumping-jenkins-credentials/jenkins-credentials-banner-low-res.jpg)
*Photo by [Stefan Steinbauer](https://unsplash.com/photos/HK8IoD-5zpg?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on Unsplash*

Most pipelines requires secrets to authenticate with some external resources.  
All secrets should live outside of our code repository and should be fed directly into the pipeline.   
Jenkins offers a credentials store where we can keep our secrets and access them from jobs.

## Credentials storage

I did not use the word "secure" anywhere in the introduction because the way any CI server stores credentials is by nature insecure.

CI servers cannot use one-way hashes (like bcrypt) to encode secrets because when requested by the pipeline those secrets needs to be restored back into their original form.  
One-way hashes are then out of the picture, what's left is two-way encryption.  
This means two things:
1. Anyone with "Create jobs" permissions can view secrets in plain form.
2. Jenkins encrypts secrets at rest but keeps the decryption key somewhere on its host.

You may be wondering why Jenkins even bother encrypting the secrets if they can be retrieved just by asking.
The only reasonable idea that comes to my mind is that Jenkins creators wanted to make it a little bit harder to gain access to plain format secrets when the attacker gains ssh access to the Jenkins host.

However, using credentials store is infinitely better then keeping secrets in the project repository.  
Later in this post I will talk about what can be done to minimize the secrets leakage from Jenkins.

## Creating credentials

If you want to run the examples yourself, you can spin up a pre-made Jenkins instance from my [jenkinsfile-examples][0] repository in less then 1min (depending on your bandwidth):

```bash
git clone https://github.com/hoto/jenkinsfile-examples.git
docker-compose pull
docker-compose up

```

Open `localhost:8080` where you should see a Jenkins with couple of jobs.

## Jenkinsfile access

We will be focusing on job `130-accessing-credentials`. 

![](./images/2019-05-27-accessing-and-dumping-jenkins-credentials/001.png)

Job `130-accessing-credentials` has a following [Jenkinsfile][1]:

```groovy
pipeline {
  agent any
  stages {

    stage('usernamePassword') {
      steps {
        script {
          withCredentials([
            usernamePassword(credentialsId: 'gitlab',
              usernameVariable: 'username',
              passwordVariable: 'password')
          ]) {
            print 'username=' + username + 'password=' + password

            print 'username.collect { it }=' + username.collect { it }
            print 'password.collect { it }=' + password.collect { it }
          }
        }
      }
    }

    stage('usernameColonPassword') {
      steps {
        script {
          withCredentials([
            usernameColonPassword(
              credentialsId: 'gitlab',
              variable: 'userpass')
          ]) {
            print 'userpass=' + userpass
            print 'userpass.collect { it }=' + userpass.collect { it }
          }
        }
      }
    }

    stage('string (secret text)') {
      steps {
        script {
          withCredentials([
            string(
              credentialsId: 'joke-of-the-day',
              variable: 'joke')
          ]) {
            print 'joke=' + joke
            print 'joke.collect { it }=' + joke.collect { it }
          }
        }
      }
    }

    stage('sshUserPrivateKey') {
      steps {
        script {
          withCredentials([
            sshUserPrivateKey(
              credentialsId: 'production-bastion',
              keyFileVariable: 'keyFile',
              passphraseVariable: 'passphrase',
              usernameVariable: 'username')
          ]) {
            print 'keyFile=' + keyFile
            print 'passphrase=' + passphrase
            print 'username=' + username
            print 'keyFile.collect { it }=' + keyFile.collect { it }
            print 'passphrase.collect { it }=' + passphrase.collect { it }
            print 'username.collect { it }=' + username.collect { it }
            print 'keyFileContent=' + readFile(keyFile)
          }
        }
      }
    }

    stage('dockerCert') {
      steps {
        script {
          withCredentials([
            dockerCert(
              credentialsId: 'production-docker-ee-certificate',
              variable: 'DOCKER_CERT_PATH')
          ]) {
            print 'DOCKER_CERT_PATH=' + DOCKER_CERT_PATH
            print 'DOCKER_CERT_PATH.collect { it }=' + DOCKER_CERT_PATH.collect { it }
            print 'DOCKER_CERT_PATH/ca.pem=' + readFile("$DOCKER_CERT_PATH/ca.pem")
            print 'DOCKER_CERT_PATH/cert.pem=' + readFile("$DOCKER_CERT_PATH/cert.pem")
            print 'DOCKER_CERT_PATH/key.pem=' + readFile("$DOCKER_CERT_PATH/key.pem")
          }
        }
      }
    }

  }
}

```

All examples for different types of secrets can be found in the official Jenkins [documentation][2]

Running the job and checking the logs uncovers that Jenkins tries to redact the secrets from the build log by matching for secrets values and replacing them with stars `****`.

![](./images/2019-05-27-accessing-and-dumping-jenkins-credentials/002.png)

![](./images/2019-05-27-accessing-and-dumping-jenkins-credentials/003.png)



[0]: https://github.com/hoto/jenkinsfile-examples
[1]: https://github.com/hoto/jenkinsfile-examples/blob/master/jenkinsfiles/130-credentials-masking.groovy 
[2]: https://jenkins.io/doc/pipeline/steps/credentials-binding/