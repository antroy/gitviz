#!/usr/bin/ruby

require 'erb'
require 'tempfile'

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
    lineage = git("log --reverse --first-parent --pretty=format:\"%h\" #{master[0]}")
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
    nodes = []

    master_lineage = get_master_lineage
    nodes << master_lineage
    merged = merged_branches

    merged.each do |data|
        data[:parents].each do |parent|
            commits = git "log --reverse --first-parent --pretty=format:\"%h\" #{parent}"
            nodes << commits
        end
    end
    nodes
end

def dot_graph(git_repo)
    nodes = get_nodes git_repo

    graph_templ = <<EOF
    strict digraph bob {
        splines=line;
        <% nodes.each_with_index do |branch, i| %>
        node[group=<%= i %>]
        <% quoted_branch = branch.map{|br| "\\"%s\\"" % br} %>
        <%= quoted_branch.join(' -> ') %>;
        <% end %>

        <% deco_map.each do |k,v| %>
        subgraph "<%= k %>" {
            rank="same"
            <% fill_colour = v.include?("tag:") ? "#ffffdd" : "#ddddff" %>
            "<%= v.strip %>" [shape="box", style="filled", fillcolor="<%= fill_colour %>"];
            "<%= v.strip %>" -> "<%= k %>"  [weight=0, arrowtype="none", dirtype="none", arrowhead="none", style="dotted"];
        }
        <% end %>


    }
EOF

    templ = ERB.new graph_templ

    dotfile = File.new "/tmp/dotfile.dot", "w"
    begin
        dotfile.write(templ.result(binding))
        png_file = "/tmp/pngfile.svg"

        IO::popen("dot -Tsvg #{dotfile.path} -o #{png_file}")
        png_file
    ensure
        dotfile.close
    end
end

def display_png(png_file)
    require 'tk'

    $resultsVar = TkVariable.new
    root = TkRoot.new
    root.title = "RepoNameHere"

    image = TkPhotoImage.new
    image.file = png_file

    label = TkLabel.new(root) 
    label.image = image
    label.place('height' => image.height, 
                'width' => image.width, 
                'x' => 10, 'y' => 10)
    Tk.mainloop
end

Dir.chdir git_repo do
    png_name = dot_graph git_repo
    puts "open #{png_name}"
end

