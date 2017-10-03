package jjformat;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;

import com.google.googlejavaformat.java.Formatter;

import static org.apache.commons.lang3.StringEscapeUtils.escapeHtml4;

public class JJFormat {

	private final static String JJ_ORIG = "origine";
	private final static String JJ_NORMALIZED = "normalized";
	private final static String JJ_FORMATTED = "formatted";
	private final static String JJ_HTML = "html";
	private final static String JJ_JAVA = "java";

	private final static Map<String, String> exts = new HashMap<>();
	static {
		exts.put(JJ_ORIG, ".javajet");
		exts.put(JJ_NORMALIZED, ".javajet");
		exts.put(JJ_FORMATTED, ".javajet");
		exts.put(JJ_HTML, ".html");
		exts.put(JJ_JAVA, ".java");
	}

	Map<String, String> jj_versions = new HashMap<String, String>();

	private Options options = new Options();
	private File jj_file;
	private File out_dir;
	private String name_output = "";
	private boolean debug = false;
	private boolean moreparenth = true;

	public static void main(String[] args) {
		JJFormat jjf = new JJFormat();
		jjf.configure(args);
		jjf.process();
	}

	public JJFormat() {
		this.buildOptions();
	}

	public void process() {
		this.readFile();
		this.normalize();
		this.format();
		this.transform2HTML();
		this.onlyJava();
		this.writeVersions();
	}

	private void onlyJava() {
		String content = this.jj_versions.get(JJ_NORMALIZED);

		content = content.replaceAll("<%=[ a-zA-Z-_().]*?%>", "");
		content = content.replaceAll("@", "\n//@");
		content = content.replaceAll("%>.*?<%", "\nSystem.out.println(\"Java jet code ...\");\n");
		content = content.replaceAll(";", ";\n");

		String begin = content.substring(0, 2);
		if("<%".equals(begin)){
			content = content.substring(2, content.length());
		}
		
		content = content.replaceAll("%>(.|\\s)*", ""); // remove last javajet code
		content = "public class Gen {\npublic static void main(String[] args) {\n" + content + " // END.\n}\n}";
		try {
			content = new Formatter().formatSource(content);
		} catch (Exception e) {
			System.out.println("Can't formated java output : " + e.getMessage());
			System.out.println("Use personal formatter...");
			e.printStackTrace();
			
			content = this.formatJava(content, false);
		}

		this.jj_versions.put(JJ_JAVA, content);
	}

	private void transform2HTML() {
		String content = this.jj_versions.get(JJ_FORMATTED);

		content = escapeHtml4(content);

		content = "<div><pre><code>\n" + content;

		content = content.replaceAll("\n&lt;%",
				"\n</code></pre></div>\n<div style=\"background-color: #ffffe6;\"><pre style=\"margin: 0px\"><code class=\"java\">\n&lt;%");
		content = content.replaceAll("\n%&gt;",
				"\n%&gt;\n</code></pre></div>\n<div style=\"background-color: #e6ffff;\"><pre style=\"margin: 0px\"><code class=\"java\">\n");

		content = "<html><header>" +
					//"<link rel=\"stylesheet\" href=\"http://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/styles/default.min.css\">" +
					//"<script src=\"http://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/highlight.min.js\"></script>" +
					//"<script>hljs.initHighlightingOnLoad();</script>" +
					"</header><body>" + content + "</body></html>";

		this.jj_versions.put(JJ_HTML, content);
	}

	private void format() {
		String content = this.jj_versions.get(JJ_NORMALIZED);
		content = formatJava(content, this.debug);
		this.jj_versions.put(JJ_FORMATTED, content);
	}

	private String formatJava(String content, boolean debug) {
		String java_parenthesis_flow = "";

		// String content = this.jj_versions.get(JJ_NORMALIZED);

		content = content.replaceAll("\"@\\{[a-zA-Z.-_]+\\}", "\"@xxxxxx");
		content = content.replaceAll("<%([^=])", "\n<%\n$1");
		content = content.replaceAll("%>", "\n%>\n");
		content = content.replaceAll("<%=(.*)\n", "<%=$1");
		content = content.replaceAll("<%=(.*)%>\n", "<%=$1%>");
		content = content.replaceAll("for[ ]*\\(([^;\n]+);([^;\n]+);([^)\n]+)\\)", "for($1| $2| $3)");
		content = content.replaceAll(";", ";\n");
		content = content.replaceAll("\\{", "\\{\n");
		content = content.replaceAll("\\}", "\\}\n");

		String newContent = "";
		try {
			Scanner sc = new Scanner(new ByteArrayInputStream(content.getBytes(StandardCharsets.UTF_8.name())))
					.useDelimiter("\n");
			while (sc.hasNext()) {
				String l = sc.next();
				l = l.trim();
				if (l.equals("")) {
					continue;
				}

				newContent += l + "\n";
			}

		} catch (Exception e) {
			System.out.println("Can't format content : " + e.getMessage());
			e.printStackTrace();
		}

		try {
			char[] cc = newContent.toCharArray();
			boolean is_java = false;
			char prev = 'x';
			int tab_java = 0;
			int tab_jj = 0;
			newContent = "";
			String java_line = "";
			boolean is_java_parenthesis_line = false;
			for (int numcar = 0; numcar < cc.length; numcar++) {
				char c = cc[numcar];
				char next = 'X';
				if (numcar < cc.length - 1) {
					next = cc[numcar + 1];
				}

				if (c == '%' && prev == '<') {
					is_java = true;
				}

				if (c == '>' && prev == '%') {
					is_java = false;
				}

				if (c == '{') {
					if (is_java) {
						tab_java++;
						is_java_parenthesis_line = true;
					} else {
						tab_jj++;
					}
				}

				if (is_java && c == '}') {
					is_java_parenthesis_line = true;
				}

				newContent += c;
				java_line += c;

				if (c == '\n') {

					if (next == '}') {
						if (is_java) {
							tab_java--;
						} else {
							tab_jj--;
						}
						if (moreparenth && (tab_java < 0 || tab_jj < 0)) {
							throw new Exception("Nb tab can't be negative");
						}
					}

					int nb = is_java ? tab_java : tab_jj;

					if (is_java_parenthesis_line) {
						java_parenthesis_flow += java_line;
						is_java_parenthesis_line = false;
					}
					java_line = "";

					for (int i = 0; i < nb; i++) {
						newContent += "    ";

						if (is_java_parenthesis_line) {
							java_parenthesis_flow += "    ";
						}
					}
				}

				prev = c;
			}

			System.out.println("Nb Java open parathesis not closed : " + tab_java);
			System.out.println("Nb JavaJet open parathesis not closed : " + tab_jj);
		} catch (Exception e) {
			System.out.println("Can't format : " + e.getMessage());
			e.printStackTrace();
		}

		newContent = newContent.replaceAll(" *<% *", "<%");
		newContent = newContent.replaceAll(" *%> *", "%>");

		if (debug) {
			// java_parenthesis_flow = "public class GenDebugParenthesis {\n
			// public static void main(String[] args) {\n" +
			// java_parenthesis_flow+"\n}\n}\n}";
			/*
			 * try{ java_parenthesis_flow = new
			 * Formatter().formatSource(java_parenthesis_flow); }
			 * catch(Exception e){
			 * System.out.println("Can't formated java parenthesis class : " +
			 * e.getMessage()); e.printStackTrace(); }
			 */

			this.writeAFile("java_parenthesis", java_parenthesis_flow, ".java");
		}

		// this.jj_versions.put(JJ_FORMATTED, newContent);
		return newContent;
	}

	private void normalize() {
		String content = this.jj_versions.get(JJ_ORIG);

		content = content.replaceAll("\\s+", " ");

		this.jj_versions.put(JJ_NORMALIZED, content);
	}

	private void writeVersions() {
		jj_versions.forEach((k, v) -> writeAVersion(k, v));
	}

	private void writeAVersion(String file, String content) {
		this.writeAFile(file, content, exts.get(file));
	}

	private void writeAFile(String file, String content, String ext) {
		try {
			File out = new File(this.out_dir, name_output + file + ext);
			PrintWriter pw = new PrintWriter(out);
			pw.write(content);
			pw.close();

		} catch (Exception e) {
			System.out.println("Can't write file " + file);
			e.printStackTrace();
		}
	}

	private void readFile() {
		try {
			FileReader fr = new FileReader(this.jj_file);
			BufferedReader br = new BufferedReader(fr);

			String l = "";
			String content = "";
			boolean first = true;
			while ((l = br.readLine()) != null) {
				if (!first) {
					content += "\n";
				}
				l = l.replaceFirst("//.*", "");
				content += l;
				first = false;
			}

			jj_versions.put(JJ_ORIG, content);
		} catch (Exception e) {
			System.out.println("Can't read javajet file : " + e.getMessage());
			e.printStackTrace();
		}
	}

	private void buildOptions() {
		Option oFile = new Option("file", true, "Javajet input file");
		oFile.setRequired(true);
		options.addOption(oFile);

		Option oOut_dir = new Option("out_dir", true, "Output directory");
		oOut_dir.setRequired(true);
		options.addOption(oOut_dir);

		Option oName = new Option("name", false, "Name output with component name");
		oName.setRequired(false);
		options.addOption(oName);

		Option gen_debug = new Option("debug", false, "Generate debug files");
		gen_debug.setRequired(false);
		options.addOption(gen_debug);
		
		Option help = new Option("help", false, "Display usage");
		help.setRequired(false);
		options.addOption(help);
		
		Option moreparenth = new Option("moreparenth", false, "D'ont throw an exception when there are more closing parenthesis (the open can come from another file)");
		moreparenth.setRequired(false);
		options.addOption(moreparenth);
		
	}

	public void configure(String[] args) {
		try {
			CommandLineParser clp = new DefaultParser();
			CommandLine cl = clp.parse(this.options, args);

			String fileValue = cl.getOptionValue("file");
			jj_file = new File(fileValue);
			if (!jj_file.exists()) {
				throw new FileNotFoundException("Given file doesn't exist : " + fileValue);
			}

			String dirout_value = cl.getOptionValue("out_dir");
			out_dir = new File(dirout_value);
			if (!out_dir.exists()) {
				throw new FileNotFoundException("Given output directory doesn't exist : " + dirout_value);
			}

			if (!out_dir.isDirectory()) {
				throw new FileNotFoundException("Given output files directory is not a directory : " + dirout_value);
			}

			if (cl.hasOption("name")) {
				this.name_output = jj_file.getName().split("\\.")[0] + "_";
			}

			if (cl.hasOption("debug")) {
				this.debug = true;
			}
			
			if (cl.hasOption("help")) {
				this.displayUsage();
			}
			
			if(cl.hasOption("moreparenth")){
				this.moreparenth = false;
			}

		} catch (Exception e) {
			System.out.println("Can't parse parameters : " + e.getMessage());
			e.printStackTrace();
		}
	}

	private void displayUsage() {
		HelpFormatter hf = new HelpFormatter();
		hf.printHelp("JJFormat", "This command parse a java jet file to generate another files which help developpers. The main one is xxx_html.html which disinguish java code and generate code with panel of different colors. The code is well formatted too. The number of parenthesis/identatoin is count and should be 0 at the end of the parsing.", this.options, "Example : java -jar target/jjformat-0.0.1-SNAPSHOT-jar-with-dependencies.jar -file /c/Dev/github2/tdi-studio-se/main/plugins/org.talend.designer.components.localprovider/components/tVerticaBulkExec/tVerticaBulkExec_end.javajet -out_dir /c/temp/tVerticaBulkExec/ -name -debug");
		System.exit(0);
	}
	
}
