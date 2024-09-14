import 'dart:io';

class CicdGenerator {
  onCicdGenerate() {}

  githubCicd() {
    final ciFile = File('.github/workflows/ci.yml');
    if(ciFile.existsSync()){
      
    }
  }

  gitlabCicd() {}
}
