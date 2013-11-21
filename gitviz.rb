#!/usr/bin/ruby

#private Dictionary<string, string> DecorateDictionary = new Dictionary<string, string>();
#private List<List<string>> Nodes = new List<List<string>>();
#    
#    private string DotFilename = Directory.GetParent(Application.ExecutablePath) + @"\" + Application.ProductName + ".dot";
#            private string PdfFilename = Directory.GetParent(Application.ExecutablePath) + @"\" + Application.ProductName + ".pdf";
#                    private string LogFilename = Directory.GetParent(Application.ExecutablePath) + @"\" + Application.ProductName + ".log";
#                            string RepositoryName;
#
#            string[] MergedColumns;
#            string[] MergedParents;
#
#            Status("Getting git commit(s) ...");
#            Result = Execute(Reg.Read("GitPath"), "--git-dir \"" + Reg.Read("GitRepositoryPath") + "\\.git\" log --all --pretty=format:\"%h|%p|%d\"");

git_repo = ARGV && ARGV[0] || "."
nodes = []

def git(command)
    IO::popen("git #{command}") do |io|
        out = io.read().split("\n")
        out.map {|line| line.strip}
        out
    end
end

deco_map = {}

Dir.chdir git_repo do
    commits = git "log --all --pretty=format:\"%h|%p|%d\""
    if commits.empty?
        puts "Unable to get get branch or branch empty ..."
    else
        commits.each do |line| 
            puts line
#                File.AppendAllText(LogFilename, "[commit(s)]\r\n");
#                File.AppendAllText(LogFilename, Result + "\r\n");
#                string[] DecorateLines = Result.Split('\n');
#                foreach (string DecorateLine in DecorateLines)
#                {
#                    MergedColumns = DecorateLine.Split('|');
            cols = line.split('|')
#                    if (!String.IsNullOrEmpty(MergedColumns[2]))
#                    {
#                        DecorateDictionary.Add(MergedColumns[0], MergedColumns[2]);
#                    }
            if cols[2]
                deco_map[cols[0]] = cols[2]
            end
#                }
#                Status("Processed " + DecorateDictionary.Count + " decorate(s) ...");
#            }
    end

    puts deco_map
#
#            Status("Getting git ref branch(es) ...");
#            Result = Execute(Reg.Read("GitPath"), "--git-dir \"" + Reg.Read("GitRepositoryPath") + "\\.git\" for-each-ref --format=\"%(objectname:short)|%(refname:short)\" "); //refs/heads/
    branches = git "for-each-ref --format=\"%(objectname:short)|%(refname:short)\" "
#            if (String.IsNullOrEmpty(Result))
#            {
#                Status("Unable to get get branch or branch empty ...");
#            }
    if branches.empty?
        puts "Unable to get get branch or branch empty ..."
#            else
    else
#            {
#                File.AppendAllText(LogFilename, "[ref branch(es)]\r\n");
#                File.AppendAllText(LogFilename, Result + "\r\n");
#                string[] RefLines = Result.Split('\n');
#                foreach (string RefLine in RefLines)
        branches.each do |line|
#                {
#                    if (!String.IsNullOrEmpty(RefLine))
#                    {
#                        string[] RefColumns = RefLine.Split('|');
            refs = line.split('|')
            puts "%s : %s" % refs
#                        if (!RefColumns[1].ToLower().StartsWith("refs/tags"))
#                        if (RefColumns[1].ToLower().Contains("master"))
            if refs[1].include?("master")
#                        {
#                            Result = Execute(Reg.Read("GitPath"), "--git-dir \"" + Reg.Read("GitRepositoryPath") + "\\.git\" log --reverse --first-parent --pretty=format:\"%h\" " + RefColumns[0]);
                parents = git("log --reverse --first-parent --pretty=format:\"%h\" ")
                parents << refs[0]
                puts "Parent: #{parents}"
#                            if (String.IsNullOrEmpty(Result))
#                            {
#                                Status("Unable to get commit(s) ...");
#                            }
#                            else
#                            {
#                                string[] HashLines = Result.Split('\n');
#                                Nodes.Add(new List<string>());
#                                foreach (string HashLine in HashLines)
#                                {
#                                    Nodes[Nodes.Count - 1].Add(HashLine);
#                                }
#                            }
#                        }
#                    }
#                }
            end
        end
    end
#                foreach (string RefLine in RefLines)
#                {
#                    if (!String.IsNullOrEmpty(RefLine))
#                    {
#                        string[] RefColumns = RefLine.Split('|');
#                        if (!RefColumns[1].ToLower().StartsWith("refs/tags"))
#                        if (!RefColumns[1].ToLower().Contains("master"))
#                        {
#                            Result = Execute(Reg.Read("GitPath"), "--git-dir \"" + Reg.Read("GitRepositoryPath") + "\\.git\" log --reverse --first-parent --pretty=format:\"%h\" " + RefColumns[0]);
#                            if (String.IsNullOrEmpty(Result))
#                            {
#                                Status("Unable to get commit(s) ...");
#                            }
#                            else
#                            {
#                                string[] HashLines = Result.Split('\n');
#                                Nodes.Add(new List<string>());
#                                foreach (string HashLine in HashLines)
#                                {
#                                    Nodes[Nodes.Count - 1].Add(HashLine);
#                                }
#                            }
#                        }
#                    }
#                }
#            }
#
#            Status("Getting git merged branch(es) ...");
#            Result = Execute(Reg.Read("GitPath"), "--git-dir \"" + Reg.Read("GitRepositoryPath") + "\\.git\" log --all --merges --pretty=format:\"%h|%p\"");
#            if (String.IsNullOrEmpty(Result))
#            {
#                Status("Unable to get get branch or branch empty ...");
#            }
#            else
#            {
#                File.AppendAllText(LogFilename, "[merged branch(es)]\r\n");
#                File.AppendAllText(LogFilename, Result + "\r\n");
#                string[] MergedLines = Result.Split('\n');
#                foreach (string MergedLine in MergedLines)
#                {
#                    MergedColumns = MergedLine.Split('|');
#                    MergedParents = MergedColumns[1].Split(' ');
#                    if (MergedParents.Length > 1)
#                    {
#                        for (int i = 1; i < MergedParents.Length; i++)
#                        {
#                            Result = Execute(Reg.Read("GitPath"), "--git-dir \"" + Reg.Read("GitRepositoryPath") + "\\.git\" log --reverse --first-parent --pretty=format:\"%h\" " + MergedParents[i]);
#                            if (String.IsNullOrEmpty(Result))
#                            {
#                                Status("Unable to get commit(s) ...");
#                            }
#                            else
#                            {
#                                string[] HashLines = Result.Split('\n');
#                                Nodes.Add(new List<string>());
#                                foreach (string HashLine in HashLines)
#                                {
#                                    Nodes[Nodes.Count - 1].Add(HashLine);
#                                }
#                                Nodes[Nodes.Count - 1].Add(MergedColumns[0]);
#                            }
#                        }
#                    }
#                }
#            }
#
#            Status("Processed " + Nodes.Count + " branch(es) ...");
#
#            StringBuilder DotStringBuilder = new StringBuilder();
#            Status("Generating dot file ...");
#            DotStringBuilder.Append("strict digraph \"" + RepositoryName + "\" {\r\n");
#            //DotStringBuilder.Append("  splines=line;\r\n");
#            for (int i = 0; i < Nodes.Count; i++)
#            {
#                DotStringBuilder.Append("  node[group=\"" + (i + 1) + "\"];\r\n");
#                DotStringBuilder.Append("  ");
#                for (int j = 0; j < Nodes[i].Count; j++)
#                {
#                    DotStringBuilder.Append("\"" + Nodes[i][j] + "\"");
#                    if (j < Nodes[i].Count - 1)
#                    {
#                        DotStringBuilder.Append(" -> ");
#                    }
#                    else
#                    {
#                        DotStringBuilder.Append(";");
#                    }
#                }
#                DotStringBuilder.Append("\r\n");
#            }
#
#            int DecorateCount = 0;
#            foreach(KeyValuePair<string, string> DecorateKeyValuePair in DecorateDictionary)
#            {
#                DecorateCount++;
#                DotStringBuilder.Append("  subgraph Decorate" + DecorateCount + "\r\n");
#                DotStringBuilder.Append("  {\r\n");
#                DotStringBuilder.Append("    rank=\"same\";\r\n");
#                if (DecorateKeyValuePair.Value.Trim().Substring(0, 5) == "(tag:")
#                {
#                    DotStringBuilder.Append("    \"" + DecorateKeyValuePair.Value.Trim() + "\" [shape=\"box\", style=\"filled\", fillcolor=\"#ffffdd\"];\r\n");
#                }
#                else
#                {
#                    DotStringBuilder.Append("    \"" + DecorateKeyValuePair.Value.Trim() + "\" [shape=\"box\", style=\"filled\", fillcolor=\"#ddddff\"];\r\n");
#                }
#                DotStringBuilder.Append("    \"" + DecorateKeyValuePair.Value.Trim() + "\" -> \"" + DecorateKeyValuePair.Key + "\" [weight=0, arrowtype=\"none\", dirtype=\"none\", arrowhead=\"none\", style=\"dotted\"];\r\n");
#                DotStringBuilder.Append("  }\r\n");
#            }
#
#            DotStringBuilder.Append("}\r\n");
#            File.WriteAllText(@DotFilename, DotStringBuilder.ToString());
#
#            Status("Generating version tree ...");
#            Process DotProcess = new Process();
#            DotProcess.StartInfo.UseShellExecute = false;
#            DotProcess.StartInfo.CreateNoWindow = true;
#            DotProcess.StartInfo.RedirectStandardOutput = true;
#            DotProcess.StartInfo.FileName = GraphvizDotPathTextBox.Text;
#            DotProcess.StartInfo.Arguments = "\"" + @DotFilename + "\" -Tpdf -Gsize=10,10 -o\"" + @PdfFilename + "\"";
#            DotProcess.StartInfo.WindowStyle = ProcessWindowStyle.Hidden;
#            DotProcess.Start();
#            DotProcess.WaitForExit();
#
#            DotProcess.StartInfo.Arguments = "\"" + @DotFilename + "\" -Tps -o\"" + @PdfFilename.Replace(".pdf", ".ps") + "\"";
#            DotProcess.Start();
#            DotProcess.WaitForExit();
#            if (DotProcess.ExitCode == 0)
#            {
#                if (File.Exists(@PdfFilename))
#                {
##if (!DEBUG)
#                    /*
#                    Process ViewPdfProcess = new Process();
#                    ViewPdfProcess.StartInfo.FileName = @PdfFilename;
#                    ViewPdfProcess.Start();
#                    //ViewPdfProcess.WaitForExit();
#                    //Close();
#                    */
##endif
#                }
#            }
#            else
#            {
#                Status("Version tree generation failed ...");
#            }
#
#            Status("Done! ...");
#        }
#    }
    end
end
