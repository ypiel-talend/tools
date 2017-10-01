package jjformat;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;

public class JJFormat {

	private Options options = new Options();
	private File jj_file;

	public static void main(String[] args) {
		JJFormat jjf = new JJFormat();
		jjf.configure(args);
		jjf.process();
	}

	public JJFormat() {
		this.buildOptions();
	}

	public void process() {
		try {
			FileReader fr = new FileReader(this.jj_file);
			BufferedReader br = new BufferedReader(fr);

			String l = "";
			String content = "";
			boolean first = true;
			while ((l = br.readLine()) != null) {
				if(!first) {
					content += "\n";
				}
				content += l;
				first = false;
			}

			System.out.println(content);
		} catch (Exception e) {
			System.out.println("Can't read javajet file : " + e.getMessage());
			e.printStackTrace();
		}
	}

	private void buildOptions() {
		Option file = new Option("file", true, "Javajet input file");
		file.setRequired(true);
		options.addOption(file);
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

		} catch (Exception e) {
			System.out.println("Can't parse parameters : " + e.getMessage());
			e.printStackTrace();
		}
	}

}
