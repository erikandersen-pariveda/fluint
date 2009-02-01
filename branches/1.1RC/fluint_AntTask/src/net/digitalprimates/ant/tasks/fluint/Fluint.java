package net.digitalprimates.ant.tasks.fluint;

import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Vector;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.DirectoryScanner;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.Execute;
import org.apache.tools.ant.types.Commandline;
import org.apache.tools.ant.types.FileSet;

public class Fluint extends Task
{
	// private static final String WINDOWS_CMD = "rundll32
	// url.dll,FileProtocolHandler ";
	// private static final String UNIX_CMD = "gflashplayer ";
	// private static final String MAC_CMD = "open ";
	private String testRunner; // TestRunner SWF
	private String outputDir;
	private Boolean headless = true;
	private Vector<FileSet> filesets = new Vector<FileSet>();
	private File outputDirFile;

	public boolean debug = false;
	protected Commandline cmdl;


	public boolean isDebug()
	{
		return this.debug;
	}


	public void setDebug(boolean debug)
	{
		this.debug = debug;
	}


	public Boolean getHeadless()
	{
		return this.headless;
	}


	public void setHeadless(Boolean headless)
	{
		this.headless = headless;
	}


	public String getTestRunner()
	{
		return this.testRunner;
	}


	public void setTestRunner(String testrunner)
	{
		this.testRunner = testrunner;
	}


	public String getOutputDir()
	{
		return this.outputDir;
	}


	public void setOutputDir(String dir)
	{
		this.outputDir = dir;
		// make sure the folder exists.
		this.outputDirFile = this.getProject().resolveFile(dir);
		if (!this.outputDirFile.exists())
		{
			this.outputDirFile.mkdir();
		}
	}


	public void addFileSet(FileSet fileset)
	{
		this.filesets.add(fileset);
	}


	public String[] prepareArguments()
	{
		ArrayList<String> args = new ArrayList<String>();

		String[] includedFiles = null;
		String[] resolvedFiles = null;
		if (this.filesets != null && this.filesets.size() > 0)
		{
			for (Iterator<FileSet> itFSets = this.filesets.iterator(); itFSets
					.hasNext();)
			{
				FileSet fs = itFSets.next();
				DirectoryScanner ds = fs.getDirectoryScanner();
				includedFiles = ds.getIncludedFiles();
				resolvedFiles = new String[includedFiles.length];

				for (int i = 0; i < includedFiles.length; i++)
				{
					String filename = includedFiles[i].replace('\\', '/');
					filename = filename
							.substring(filename.lastIndexOf("/") + 1);
					File base = ds.getBasedir();
					File found = new File(base, includedFiles[i]);
					resolvedFiles[i] = found.getAbsolutePath();
				}
			}
		}

		if (this.headless)
		{
			args.add("-headless");
		}

		args.add("-reportDir='" + this.outputDir + "'");

		if (resolvedFiles != null && resolvedFiles.length > 0)
		{
			StringBuffer fileList = new StringBuffer();
			fileList.append("-fileSet='");

			for (int x = 0; x < resolvedFiles.length; x++)
			{
				if (x != 0)
				{
					fileList.append(",");
				}
				fileList.append(resolvedFiles[x]);
			}

			fileList.append("'");

			args.add(fileList.toString());
		}

		String[] str = new String[args.size()];
		return args.toArray(str);
	}


	@Override
	public void execute()
	{
		// todo: check and throw exception if no swf was defined

		int returnValue;
		this.testRunner = this.testRunner.replace('/', '\\');

		this.cmdl = new Commandline();
		this.cmdl.addArguments(this.prepareArguments());
		this.cmdl.setExecutable(this.testRunner);

		Execute exe = new Execute();
		exe.setAntRun(this.getProject());
		exe.setWorkingDirectory(this.getProject().getBaseDir());
		exe.setCommandline(this.cmdl.getCommandline());

		try
		{
			returnValue = exe.execute();

			if (this.isDebug())
			{
				System.out.println("DEBUG: " + this.cmdl.describeCommand());
				System.out.println("DEBUG: " + returnValue );
			}
		}
		catch (Exception e)
		{
			throw new BuildException("Unable to run " + this.testRunner + ": "
					+ e.getMessage(), e);
		}



	}

}