##
#
# latexmk configuration
#
##


# Use recorder feature to list input files
#
$recorder = 1;


# Latex Engine Selection
#
# pdf_mode values
#  1 = pdflatex
#  4 = lualatex
#
$pdf_mode = 1;


# Latex Engine configuration
# 
# Note to Mercurial repos: add the option "--shell-escape" to the engine command.
#
# pdflatex:
#   --extra-mem-bot=n  - Set the extra size (in memory words) for large data structures like boxes, glue, breakpoints, ...
#   --extra-mem-top=n  - Set the extra size (in memory words) for chars, tokens, ...
$pdflatex = 'pdflatex -interaction=nonstopmode -synctex=1 --extra-mem-bot=134217728 --extra-mem-top=134217728 %O %S';
#
# luatex:
$lualatex = 'lualatex -interaction=nonstopmode -synctex=1 %O %S';


# Disable ps and dvi output (we want just the pdf)
$postscript_mode = $dvi_mode = 0;


# Only compile the main document
#
@default_files = ("thesis");


# Run biber when necessary, but also delete the
# regeneratable bbl-file in a clenaup (`latexmk -c`). 
# Use "1" if original bib file is not available!
#
$bibtex_use = 2;


# Push new file endings into list holding those files
# that are kept and later used again (like idx, bbl, ...).
# Let latexmk know about these generated files, so they can be used to detect if a
# rerun is required, or be deleted in a cleanup.
# crlrs:      List of Corollaries
# defs:       List of Definitions
# exs:        List of Examples
# glg:        
# glstex:     
# ist:        
# loa:        List of Algorithms
# loe:        List of Examples (KOMAScript)
# lol:        List of Listings (listings package)
# mw:         
# pros:       List of Proofs 
# run.xml:   
# slg:        
# slo:        
# sls:        
# synctex:    
# synctex.gz: 
# tdo:        List of TODOs (todonotes)
# thms:       List of Theorems
#
push @generated_exts, 'crlrs', 'defs', 'exs', 'glg', 'glstex', 'ist', 'loa', 'loe', 'lol', 'mw', 'pros', 'run.xml', 'slg', 'slo', 'sls', 'synctex', 'synctex.gz', 'tdo', 'thms';


# Also delete the *.glstex files from package glossaries-extra. Problem is,
# that that package generates files of the form "basename-digit.glstex" if
# multiple glossaries are present. Latexmk looks for "basename.glstex" and so
# does not find those. For that purpose, use wildcard.
$clean_ext = "%R-*.glstex";


# The glossaries package
# (http://www.ctan.org/pkg/glossaries) and the glossaries-extra package
# (http://www.ctan.org/pkg/glossaries-extra) with latexmk.
add_cus_dep( 'acn', 'acr', 0, 'makeglossaries' );
add_cus_dep( 'glo', 'gls', 0, 'makeglossaries' );
$clean_ext .= " acr acn alg glo gls glg";
sub makeglossaries {
    my ($base_name, $path) = fileparse( $_[0] );
    pushd $path;
    my $return = system "makeglossaries", $base_name;
    popd;
    return $return;
}
