pipeline {
    agent {
        label params.LABEL
    }
    environment {
        PATH = "/s3bucket"
    }
    stages {
        stage("Write file") {
            steps {
                script {
                    echo "Stage 1"
                    def date = new Date()
                    def data = "Hello World\nSecond line\n" + date
                    def filePath = env.PATH+"/"+params.FILENAME
                    writeFile(file: filePath, text: data)
                }
            }
        }

        stage("Read file") {
            steps {
                script {
                    echo "Stage 2"
                    def filePath = env.PATH+"/"+params.FILENAME
                    def data = readFile(file: filePath)
                    println(data)
                }
            }
        }
    }
}