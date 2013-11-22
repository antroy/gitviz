#!/usr/bin/ruby

require 'erb'

git_repo = ARGV && ARGV[0] || "."

def git(command)
    IO::popen("git #{command}") do |io|
        out = io.read().split("\n")
        out.map {|line| line.strip}
        out
    end
end

def deco_map
    commits = git "log --all --pretty=format:\"%h|%d\""
    out = {}
    commits.each do |line| 
        hash, ref_names = line.split('|')
        if ref_names
            out[hash] = ref_names
        end
    end
    out
end

def get_master_lineage
    branches = git("for-each-ref --format=\"%(objectname:short)|%(refname:short)\" ").map{|line| line.split('|')}

    master = branches.find{|ref, name| name == "master"}
    puts "Master: %s" % master[0]
    lineage = git("log --reverse --first-parent --pretty=format:\"%h\" #{master[0]}")
    puts "Parent: #{lineage}"
    lineage
end

def merged_branches
    lines = git("log --all --merges --pretty=format:\"%h|%p\"")
    merged = lines.map do |line| 
        merge, parents_list = line.split "|"
        {merge: merge, parents: parents_list.split(" ")}
    end
    merged
end

def get_nodes(git_repo)
    Dir.chdir git_repo do
        nodes = []
        deco_map.each {|k,v| puts "%s: %s" % [k,v]}

        master_lineage = get_master_lineage
        nodes << master_lineage
        merged = merged_branches

        merged.each do |data|
            puts "Cols: #{data[:merge]}; par: #{data[:parents]}"
            data[:parents].each do |parent|
                commits = git "log --reverse --first-parent --pretty=format:\"%h\" #{parent}"
                puts "BLAH: " + commits.join(":")
                nodes << commits
            end
        end
        puts "All Nodes: #{nodes}"
        nodes
    end
end

def dot_graph(git_repo)
    nodes = get_nodes git_repo

    graph_templ = "
    strict digraph bob {
        splines=line;
        <% nodes.each_with_index do |branch, i| %>
        node[group=<%= i %>]
        <%= branch.join(' -> ') %>;
        <% end %>


    }
    "

    templ = ERB.new graph_templ

    puts templ.result binding
end

dot_graph git_repo

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
