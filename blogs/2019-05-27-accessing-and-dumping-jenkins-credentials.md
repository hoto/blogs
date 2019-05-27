---
title: "Accessing and dumping Jenkins credentials"
date: "2019-05-27"
---

# Accessing and dumping Jenkins credentials

Creating, accessing and dumping Jenkins credentials.

![This is an image](./images/2019-05-27-accessing-and-dumping-jenkins-credentials/jenkins-credentials-banner-low-res.jpg)
*Photo by [Stefan Steinbauer](https://unsplash.com/photos/HK8IoD-5zpg?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on Unsplash*

Most pipelines requires secrets to authenticate with some resources.  
Those secrets should live outside of our code repository and should be fed directly into the pipeline.   
Jenkins offers a credentials store where we can keep our secrets.

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



