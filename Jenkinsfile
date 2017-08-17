#!/usr/bin/env groovy
@Library('github.com/msrb/cicd-pipeline-helpers')

def commitId
node('docker') {

    def image = docker.image('fabric8-analytics/f8a-worker-base')

    stage('Checkout') {
        checkout scm
        commitId = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
    }

    stage('Build') {
        dockerCleanup()
        docker.build(image.id, '--pull --no-cache .')
    }

    if (env.BRANCH_NAME == 'master') {
        stage('Push Images') {
            docker.withRegistry('https://push.registry.devshift.net/', 'devshift-registry')
                image.push('latest')
                image.push(commitId)
            }
        }
    }

}
