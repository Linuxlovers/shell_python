def label = "mypod-${UUID.randomUUID().toString()}"
def project = 'arch'
def appName = 'workmanage'
def appVersion='1'
def imagePre = "10.10.70.65/${project}/${appName}:${appVersion}"
podTemplate(label: label, containers: [
    containerTemplate(name: 'maven', image: '10.10.70.65/base/ionic-maven:1.1',alwaysPullImage: true, ttyEnabled: true, command: 'cat',resourceRequestCpu: '200m', resourceRequestMemory: '4096Mi',resourceLimitCpu: '200m', resourceLimitMemory: '4096Mi')
  ],volumes:[hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock'),hostPathVolume(hostPath: '/usr/bin/docker', mountPath: '/usr/bin/docker')]) {
    node(label) {
        stage('Get a Maven project') {
            def svnVars=checkout([$class: 'SubversionSCM', additionalCredentials: [], excludedCommitMessages: '', excludedRegions: '', excludedRevprop: '', excludedUsers: '', filterChangelog: false, ignoreDirPropChanges: false, includedRegions: '', locations: [[cancelProcessOnExternalsFail: true, credentialsId: 'df6b9ff6-cfa5-481b-8cd5-4fc2f2f63d6f', depthOption: 'infinity', ignoreExternalsOption: true, local: '.', remote: 'https://10.10.70.36/svn/THYF2017-042ResearchManagementSystem/trunk/Code&技术文档/Code/newWorkmanage']], quietOperation: true, workspaceUpdater: [$class: 'UpdateUpdater']])
            def svnversionnumber = svnVars.SVN_REVISION
            def imageName="${imagePre}-${svnversionnumber}"
            container('maven') {
			    stage('Ionic build  project') {
                    sh 'chmod 750 newWorkmanage.web/src/main/webview -R && cd newWorkmanage.web/src/main/webview && ionic build'
                    sh 'cd newWorkmanage.web/src/main/webapp && uglifyjs build/main.js -o build/main.min.js && gzip -9 -S gz build/main.min.js'
                }
                stage('Build a Maven project') {
                    sh 'mvn clean'
                    sh 'mvn package'
                }
              //  stage('SonarQube analysis') {
               //     withSonarQubeEnv('SonarqubeServer') {
                      // requires SonarQube
                  //    sh 'mvn sonar:sonar'
                  //  }
                // }
              stage('Build Docker Image') {
                    sh 'mv newWorkmanage.web/target/*.war docker/'
                    sh( "cd docker/ && docker build . -t ${imageName}")
                }
             stage('Push Docker Image') {
                    sh ("docker login -u admin -p Harbor12345 10.10.70.65 && docker push ${imageName}")
                }
        }

    }
}
}