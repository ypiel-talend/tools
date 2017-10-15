# JavaJet formatter #

JJFormat is a small tool, quickly developped with some dirty code, to help in readibility of java jet files. It parses a javajet file and generate some others into a selected folder:
* It copies original file
* It normalizes it in one line output
* It formats javajet sections and generated sections with two differents identation increase
* It generates an html file with syntax highlight and well distinguished sections
* It generates a pure java file with all generated section replaced by sysout

## Build ##
This project uses _maven-assembly-plugin_ to generate one jar with all its needed dependencies inside. It is configured to generate the assembly jar in package phase. So you only have to do `mvn clean package` then it generates jjformat-_version_-jar-with-dependencies.jar in target folder.

## Usage ##
