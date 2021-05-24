pipeline {
   agent { label 'docker' }

   environment {
       COMPOSE_FILE="docker-compose.test.yml"
   }

   stages {
      stage("Setup") {
        steps {
          sh './scripts/setup.sh'
          sh 'docker-compose run web scripts/setup_db.sh'
        }
      }
      stage("Run Tests") {
        parallel {
          stage("Run Rspec") {
            steps {
              sh 'docker-compose run --name tests web sh scripts/run_tests.sh'
            }
          }
          stage("Run Rubocop") {
            steps {
              sh 'docker-compose run --name linter web sh scripts/lint.sh'
            }
          }
        }
      }
   }

   post {
      cleanup { // Always runs after all other post conditions
        sh './scripts/cleanup.sh'
      }
    }
}
