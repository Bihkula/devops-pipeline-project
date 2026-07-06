pipeline {
    agent {
        kubernetes {
            serviceAccount 'jenkins-deployer'
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kubectl
    image: bitnami/kubectl:1.35
    command:
    - sleep
    args:
    - 99d
'''
        }
    }

    parameters {
        string(name: 'IMAGE_TAG', defaultValue: 'latest', description: 'Image tag to promote')
    }

    stages {
        stage('Deploy to Staging') {
            steps {
                container('kubectl') {
                    sh '''
                        kubectl set image deployment/demo-app demo-app=ghcr.io/bihkula/devops-pipeline-project:${IMAGE_TAG} -n staging --record || \
                        kubectl create -f k8s/app/deployment.yaml -n staging
                        kubectl rollout status deployment/demo-app -n staging --timeout=120s
                    '''
                }
            }
        }

        stage('Smoke Test Staging') {
            steps {
                container('kubectl') {
                    sh '''
                        kubectl run smoke-test --rm -i --restart=Never -n staging --image=curlimages/curl -- \
                        curl -f http://demo-app.staging.svc.cluster.local/healthz
                    '''
                }
            }
        }

        stage('Approval for Production') {
            steps {
                input message: "Promote image ${params.IMAGE_TAG} to PRODUCTION?", ok: 'Deploy to Prod'
            }
        }

        stage('Deploy to Production') {
            steps {
                container('kubectl') {
                    sh '''
                        kubectl set image deployment/demo-app demo-app=ghcr.io/bihkula/devops-pipeline-project:${IMAGE_TAG} -n prod --record || \
                        kubectl create -f k8s/app/deployment.yaml -n prod
                        kubectl rollout status deployment/demo-app -n prod --timeout=120s
                    '''
                }
            }
        }

        stage('Smoke Test Production') {
            steps {
                container('kubectl') {
                    sh '''
                        kubectl run smoke-test --rm -i --restart=Never -n prod --image=curlimages/curl -- \
                        curl -f http://demo-app.prod.svc.cluster.local/healthz
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Promotion pipeline completed successfully for image tag: ${params.IMAGE_TAG}"
        }
        failure {
            echo "❌ Promotion pipeline failed — check logs above"
        }
    }
}
