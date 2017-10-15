# JavaJet formatter #

JJFormat is a small tool, quickly developped with some dirty code, to help in readibility of java jet files. It parses a javajet file and generate some others into a selected folder:
* It copies original file
* It normalizes it in one line output
* It formats javajet sections and generated sections with two differents identation increase
* It generates an html file with syntax highlight and well distinguished sections
* It generates a pure java file with all generated section replaced by sysout

![Generated HTML](https://github.com/ypiel-talend/tools/blob/master/talend/jjformat/resources/screenshot.png)

## Build ##
This project uses _maven-assembly-plugin_ to generate one jar with all its needed dependencies inside. It is configured to generate the assembly jar in package phase. So you only have to do `mvn clean package` then it generates jjformat-_version_-jar-with-dependencies.jar in target folder.

## Usage ##
`$ java -jar target/jjformat-0.0.1-SNAPSHOT-jar-with-dependencies.jar -help`

usage: `JJFormat`

This command parse a java jet file to generate another files which help developpers. The main one is xxx_html.html which disinguishes javajet code and generated one with panel of different colors and syntax highlight. The code is well formatted too. The number of parenthesis/identation is counted and should be 0 at the end of the parsing.
```
 -debug           Generate debug files
 -file <arg>      Javajet input file
 -help            Display usage
 -moreparenth     D'ont throw an exception when there are more closing
                  parenthesis (the open can come from another file)
 -name            Name output with component name
 -out_dir <arg>   Output directory
 ```

Example :
```
java -jar target/jjformat-0.0.1-SNAPSHOT-jar-with-dependencies.jar -file /c/tdi-studio-se/main/plugins/org.talend.designer.components.localprovider/components/tVerticaBulkExec/tVerticaBulkExec_end.javajet -out_dir /c/temp/tVerticaBulkExec/ -name -debug
```